#include<stdio.h>
#include<cuda.h>
#include <string.h>
#include <math.h>
#define MAXNUM 10000000000
#define BNUM 190
#define TNUM 1024
long long MakeNum(int *number,long long size){
	int i,j,now=0;
	for(i=0;i<size;i++)
		number[i]=0;
	number[2]=1;number[3]=1;
	for(i=5,j=2;i<size;i+=j,j=6-j){
		number[i]=1;
		now++;
	}//printf("%llu %llu\n",now,number[now-1]);
	return size;
    //number[0] = 2;
}

__global__ void running(int *deviceArr,long long arrSize){
        int BID=blockIdx.x;       //區塊索引
        int TID=threadIdx.x;      //執行緒索引
        //int n=blockDim.x;       //區塊中包含的執行緒數目
        //int x=BID*n+TID;            //執行緒在陣列中對應的位置
		//deviceArr[arrSize-1]++;
		long long i,j,k;
		for(i = BID * TNUM + TID; i < arrSize;i += BNUM * TNUM){
			if(deviceArr[i]==1){
				for(j=2;i*j<arrSize;j++)
				//for (j = 5,k=2; j * i < arrSize;j+=k,k=6-k) 
				{
				  deviceArr[i * j] = 0;
				}
			}
		}
		
		
};
int main(){
		int *arr;	
		int *hostArr;
		int *deviceArr;
		long long i,j,k,arrSize,temp,biggest;
		float dTime;
		cudaEvent_t start,end;
		
		arr = (int *)malloc(MAXNUM*sizeof(int));
		hostArr = (int *)malloc(MAXNUM*sizeof(int));
		cudaEventCreate(&start);
		cudaEventCreate(&end);
		arrSize=MakeNum(arr,MAXNUM);
		//printf("%llu %llu\n",arrSize,arr[arrSize-1]);
		/*for(i=0;i<arrSize;i++)
			if(arr[i]==1)
				printf("%llu ",i);
		printf("\n",arr[i]);*/
		cudaMalloc((void**) &deviceArr, MAXNUM*sizeof(int));
		cudaMemcpy(deviceArr,arr,sizeof(int)*MAXNUM,cudaMemcpyHostToDevice);
		cudaEventRecord(start, 0);
		running<<<BNUM,TNUM>>>(deviceArr,arrSize);
		cudaEventRecord(end, 0);
		cudaEventSynchronize(end); 
		cudaMemcpy(hostArr, deviceArr, MAXNUM*sizeof(int), cudaMemcpyDeviceToHost);
		temp=0;
		for(i=0;i<arrSize;i++){
			if(hostArr[i]==1){
				temp++;
				biggest=i;
				//printf("%llu ",i);
			}
				
		}/**/
		cudaEventElapsedTime(&dTime, start, end);
		printf("2~%llu num:%llu  biggest:%llu  time:%f.\n",MAXNUM,temp,biggest,dTime);
		cudaFree(deviceArr);
		/*
        cudaMalloc((void**) &d, 100*sizeof(Index));
		
        int g=3, b=4, m=g*b;
        running<<<g,b>>>(d);

        cudaMemcpy(h, d, 100*sizeof(Index), cudaMemcpyDeviceToHost);

        for(int i=0; i<m; i++){
            printf("h[%d]={block:%d, thread:%d,%d,%d}\n", i,h[i].block,h[i].thread,h[i].n,h[i].x);
        }

        cudaFree(d);*/
		
        return 0;
}


