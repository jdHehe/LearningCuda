#include <stdio.h>

__global__ void vector_add(int *a, int *b, int *c){
  int index =  blockIdx.x * blockDim.x + threadIdx.x;
  c[index] = a[index] + b[index] ;
}

#define N(2048*2048)
#define THREADS_PER_BLOCK 512

int main(){
  int *a, *b, *c;
  int *d_a, *d_b, *d_c;

  int size = N * sizeof( int );
  //
  cudaMalloc((void **) &d_a, size);
  cudaMalloc((void **) &d_b, size);
  cudaMalloc((void **) &d_c, size);

  a = (int *)malloc(size);
  b = (int *)malloc(size);
  c = (int *)malloc(size);

  for (int i=0; i<N; i++){
    a[i] = b[i] = i;
    c[i] = 0;
  }

  // 将数据从host内存 拷贝到 gup的memory中
  cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

  add<<, THREADS_PER_BLOCK>>(d_a, d_b, d_c);
  // 将GPU计算结束的数据，拷贝到主机的内存
  cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);

  printf("c[0]= %d\n", 0, c[0])
  printf("c[%d] = %d", N-1, c[N-1]);

  // 释放内存
  free(a);
  free(b);
  free(c);
  cudaFree( d_a );
  cudaFree( d_b );
  cudaFree( d_c );

  return 0;
}
