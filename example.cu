#include <stdio.h>

__device__ const char *STR = "HELLO WORLD";
const char STR_LENGTH = 12;

__global__ void hello(){
  printf("%c\n", STR[threadIdx.x % STR_LENGTH]);
}

int main(void){
  int num_threads = STR_LENGTH;
  int num_blocks = 1;
  hello<<<num_blocks, num_threads>>>()
  //  等待所有的host 线程中执行的命令执行完毕
  cudaDeviceSynchronize();
  return 0;
}
