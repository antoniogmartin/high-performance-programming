/**
* Vector addition: C = A + B.
*
* This sample is a very basic sample that implements element by element
* vector addition. It is the same as the sample illustrating Chapter 2
* of the programming guide with some additions like error checking.
*/
#include <time.h>
#include <stdio.h>
#include <cstdlib>
#include <stdlib.h>
// For the CUDA runtime routines (prefixed with "cuda_")
#include <cuda_runtime.h>
#include "device_launch_parameters.h"


__global__ void prime_number(int * n, int * p)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	int j=0;
	int prime=1;

	   if (i < *n)
	    {
		    for ( j = 2; j < i ; j++ )
		    {
		      if ( ( i % j ) == 0 )
		      {
		        prime = 0;
		        break;
		      }
		    }
		    if(i==0||i==1)
		    	prime=0;

		    p[i]=prime;
	    }

}
 

__global__ void reduce( int *a, int *b,int * d_A) {
	
	__shared__  int cache[256];//hebras por bloque
	int tid = threadIdx.x + blockIdx.x * blockDim.x; 
	int cacheIndex = threadIdx.x;
	int temp = 0; 
	int N=*d_A;
	while (tid < N) {
	           temp += a[tid];
	           tid += blockDim.x * gridDim.x;
	}
	    // set the cache values

	     cache[cacheIndex] = temp;

	    // synchronize threads in this block
	__syncthreads();

	// for reductions, threadsPerBlock must be a power of 2 // because of the following code

	int i = blockDim.x/2;
	while (i != 0) {
	if (cacheIndex < i)
	cache[cacheIndex] += cache[cacheIndex + i];
	__syncthreads();
	i /= 2;

	}

	if (cacheIndex == 0) b[blockIdx.x] = cache[0];
}

int main(int argc, char *argv[])
{

	//Mostrar especificaciones de la máquina
	
	clock_t start_cpu, end_cpu;
	double cpu_time_used;
	if (argc != 2){
		printf("1: tama  argc %i", argc);

	}
	else{

		start_cpu = clock();
		/*
		int nDevices;
		cudaGetDeviceCount(&nDevices);
		for (int i = 0; i < nDevices; i++) {
			cudaDeviceProp prop;
			cudaGetDeviceProperties(&prop, i);
			printf("Device Number: %d\n", i);
			printf("  Device name: %s\n", prop.name);
			printf("  Memory Clock Rate (KHz): %d\n",
				prop.memoryClockRate);
			printf("  Memory Bus Width (bits): %d\n",
				prop.memoryBusWidth);
			printf("  Peak Memory Bandwidth (GB/s): %f\n\n",
				2.0*prop.memoryClockRate*(prop.memoryBusWidth / 8) / 1.0e6);
		}*/

		// Origen 
		int n=atoi(argv[1]);
		int *h_A = &n;
		

		size_t sizeTama = n * sizeof(int);
		int *h_prime= (int*) malloc(sizeTama);
		int *h_result= (int*) malloc(sizeTama);
		int *h_B= (int*) malloc(sizeTama);
		
		// Destino

		int *d_A = NULL;
		cudaMalloc((void **)&d_A, sizeof(int));

		int *d_B = NULL;
		cudaMalloc((void **)&d_B,sizeTama);

		int *d_prime=NULL;
		cudaMalloc((void **)&d_prime,sizeTama);

		int *d_result=NULL;
		cudaMalloc((void **)&d_result,sizeTama);

		//printf("NNA %i\n",*h_A);
		//printf("Copy input data from the host memory to the CUDA device\n");
		
		// Launch the Vector Add CUDA Kernel

		float elapsed = 0, elapsed2=0;

		
		int threadsPerBlock = 256;
		int blocksPerGrid = (n + threadsPerBlock - 1) / threadsPerBlock;
		
		//printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid, threadsPerBlock);

		cudaMemcpy(d_A, h_A, sizeof(int), cudaMemcpyHostToDevice);

		cudaEvent_t start, stop;
		cudaEventCreate(&start);
		cudaEventCreate(&stop);
		cudaEventRecord(start, 0);

		prime_number << <blocksPerGrid, threadsPerBlock >> >(d_A,d_prime);
		
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&elapsed, start, stop);

		 
		cudaMemcpy(h_prime, d_prime, sizeTama, cudaMemcpyDeviceToHost);

		cudaMalloc((void **)&d_prime,sizeTama);
		cudaMemcpy(d_prime, h_prime, sizeTama, cudaMemcpyHostToDevice);
		cudaMemcpy(d_A, h_A, sizeof(int), cudaMemcpyHostToDevice);

		cudaEventCreate(&start);
		cudaEventCreate(&stop);
		cudaEventRecord(start, 0);
		reduce <<<blocksPerGrid, threadsPerBlock >> >(d_prime,d_B,d_A);
		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&elapsed2, start, stop);

		cudaMemcpy(h_B, d_B, sizeTama, cudaMemcpyDeviceToHost);
		
			
		

		cudaEventDestroy(start);
		cudaEventDestroy(stop);

		int total_primes=0;

		for (int i=0;i<blocksPerGrid;i++){
			total_primes +=h_B[i];
		}
		end_cpu = clock();
		cpu_time_used = ((double)(end_cpu - start_cpu)/(CLOCKS_PER_SEC));

		printf("%i\t%f \n",n, cpu_time_used + (elapsed*0.001+elapsed2*0.001));

		// Free device global memory
		cudaFree(d_A);
		cudaFree(d_prime);

		// Free host memory
		//free(h_A);
		free(h_prime);

		cudaDeviceReset();
	}


	return 0;
}
