#include <stdio.h>
#include <cuda.h>
#include <string.h>
#include <math.h>
#include <stdbool.h>

#define BNUM 180
#define TNUM 1024
unsigned long long MakeNum(bool *number,unsigned long long size){
	unsigned long long i,j,now=0;
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

__global__ void running(bool *deviceArr,unsigned long long arrSize){
        int BID=blockIdx.x;       //區塊索引
        int TID=threadIdx.x;      //執行緒索引
        //int n=blockDim.x;       //區塊中包含的執行緒數目
        //int x=BID*n+TID;            //執行緒在陣列中對應的位置
		//deviceArr[arrSize-1]++;
		unsigned long long i,j,k;
		for(i = BID * TNUM + TID; i < arrSize;i += BNUM * TNUM){
			if(deviceArr[i]==1){
				//for(j=2;i*j<arrSize;j++)
				for (j = 5,k=2; j * i < arrSize;j+=k,k=6-k) 
				{
				  deviceArr[i * j] = 0;
				}
			}
		}
		
		
};
int main(){
	unsigned long long MAXNUM=16000000000;
while(1){
		bool *arr;	
		bool *hostArr;
		bool *deviceArr;
		unsigned long long i,arrSize,temp,biggest;
		float dTime;
		cudaEvent_t start,end;
		
		arr = (bool *)malloc(MAXNUM*sizeof(bool));
		hostArr = (bool *)malloc(MAXNUM*sizeof(bool));
		cudaEventCreate(&start);
		cudaEventCreate(&end);
		arrSize=MakeNum(arr,MAXNUM);
		//printf("%llu %llu\n",arrSize,arr[arrSize-1]);
		/*for(i=0;i<arrSize;i++)
			if(arr[i]==1)
				printf("%llu ",i);
		printf("\n",arr[i]);*/
		cudaMalloc((void**) &deviceArr, MAXNUM*sizeof(bool));
		cudaMemcpy(deviceArr,arr,sizeof(bool)*MAXNUM,cudaMemcpyHostToDevice);
		cudaEventRecord(start, 0);
		running<<<BNUM,TNUM>>>(deviceArr,arrSize);
		cudaEventRecord(end, 0);
		cudaEventSynchronize(end); 
		cudaMemcpy(hostArr, deviceArr, MAXNUM*sizeof(bool), cudaMemcpyDeviceToHost);
		temp=0;
		for(i=0;i<arrSize;i++){
			if(hostArr[i]==1){
				temp++;
				biggest=i;
				//printf("%llu ",i);
			}
				
		}/*printf("\n");*/
		cudaEventElapsedTime(&dTime, start, end);
		printf("2~%llu num:%llu  biggest:%llu  time:%f ms.\n",MAXNUM,temp,biggest,dTime);
		cudaFree(deviceArr);
		
		free(arr);free(hostArr);
		MAXNUM+=100000000;
		//if(MAXNUM>=16505000000)break;
		}
        //return 0;
}


