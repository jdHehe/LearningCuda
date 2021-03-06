#include <cuda_runtime.h>
#include <stdio.h>
/***
__shared__  通过共享内存来完成线程间的通信
这一段代码 通过共享内存
***/


cudaError_t addWithCuda(int *c, const int *a, size_t size);

__global__ void addKernel(int *c, const int *a){
    int i = threadIdx.x;
    extern __shared__ int seme []; //声明一个全局的 共享内存的变量
    seme[i] = a[i];
    __syncthreads();  //同一个块的线程同步  等待seme将所有数据加载进来
    if(i==0){ //第一个线程进行二次方
        c[0] = 0;
        for (int d=0; d<5; d++){
            printf("seme[d] * seme [d] %d \n", d);
            c[0] += seme[d] * seme [d];
        }
        printf("给 seme 赋值 %d ", i);
        seme[i] = 0;
    }
    if(i==1){
        c[1] = 0;
        for (int d=0; d<5; d++){
            printf("c[1] += seme[d] %d \n", d);
            c[1] += seme[d];
        }
        printf("给 seme 赋值 %d ", i);
        seme[i] = 0;
    }
    if(i==2){
        c[2] = 1;
        for(int d=0; d<5; d++){
            printf("c[2] *= seme[d] %d \n", d);
            c[2] *= seme[d];
        }
        printf("给 seme 赋值 %d ", i);
        seme[i] = 0;
    }
}

int main(){
    const int arraySize = 5;
    const int a[arraySize] = {1, 2, 3, 4, 5};
    int c[arraySize] = {0};
    cudaError_t cudaStatus = addWithCuda(c, a, arraySize);
    if (cudaStatus != cudaSuccess){
        fprintf(stderr, "addWithCuda 失败");
        return 1;
    }
    printf("\t1+2+3+4+5 = %d\n\t1^2+2^2+3^2+4^2+5^2 = %d\n\t1*2*3*4*5 = %d\n\n\n\n\n\n", c[1], c[0], c[2]);
    cudaStatus = cudaThreadExit();
    if (cudaStatus != cudaSuccess){
        fprintf(stderr, "cudaThreadExit 失败");
        return 1;
    }
    return 0;
}

cudaError_t addWithCuda(int *c,const int *a, size_t size){
    int *dev_a = 0;
    int *dev_c = 0;
    cudaError_t cudaStatus;
    
    cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(int));
    if (cudaStatus != cudaSuccess){
        fprintf(stderr, "cuda 分配内存失败");
        goto Error;
    }
    cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(int));
    if (cudaStatus != cudaSuccess){
        fprintf(stderr, "cuda 分配内存失败");
        goto Error;
    }
    cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess){
        fprintf(stderr, "从Device向Hostcopy数据失败");
        goto Error;
    }

    addKernel<<<1, size, size * sizeof(int), 0>>>(dev_c, dev_a);

    cudaStatus = cudaThreadSynchronize();
    if (cudaStatus != cudaSuccess){
        fprintf(stderr, "cuda线程同步异常");
        goto Error;
    }

    cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess){
        fprintf(stderr, "从Device向Hostcopy数据失败");
        goto Error;
    }

Error:
    cudaFree(dev_c);
    cudaFree(dev_a);
    return cudaStatus;
}