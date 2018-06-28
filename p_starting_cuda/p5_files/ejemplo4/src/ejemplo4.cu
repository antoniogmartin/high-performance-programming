/**
* Vector addition: C = A + B.
*
* This sample is a very basic sample that implements element by element
* vector addition. It is the same as the sample illustrating Chapter 2
* of the programming guide with some additions like error checking.
*/
#include <ctime>
#include <time.h>
#include <stdio.h>
#include <cstdlib>
#include <stdlib.h>
// For the CUDA runtime routines (prefixed with "cuda_")
#include <cuda_runtime.h>
#include "device_launch_parameters.h"
/**
* CUDA Kernel Device code
*
* Computes the vector addition of A and B into C. The 3 vectors have the same
* number of elements numElements.
*/
__global__ void vectorAdd(const float *A, const float *B, float *C, int numElements)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	
	float ai, bi, res=0;
	int j=0;
		
	   
	    ai = A[i];

	    bi=B[i];

	    if (i < numElements)
	    {
		for (j=0;j<10000;j++) res+=(ai*bi)/742;
		C[i]=A[i]+B[i];
	
	    }
	

}
//GETLINE FOR NOT-POSIX
__host__ float * readFile(char * path, int * n){

	FILE *  fp;
	fp = fopen(path, "r");
	int lineSize = 1024, pos = 0, pos2 = 0;
	int c;
	int vSize = 10;
	char *buffer = (char *)malloc(lineSize);
	float * v;

	if (fopen == NULL)
		exit(EXIT_FAILURE);

	do { // read all lines in file
		pos = 0;
		do{ // read one line
			c = fgetc(fp);
			if (c != EOF) buffer[pos++] = (char)c;
			if (pos >= lineSize - 1) { // incrementar tamañobuffer - leave room for 0
				lineSize *= 2;
				buffer = (char*)realloc(buffer, lineSize);
			}
		} while (c != EOF && c != '\n');
		buffer[pos] = 0;
		if (pos2 == 0){
			vSize = atoi(buffer);
			v = (float *)malloc(sizeof(float)*vSize);
		}
		else if (pos2 <= vSize){
			v[pos2 - 1] = atof(buffer);
		}
		pos2++;
	} while (c != EOF);

	fclose(fp);
	free(buffer);

	*n = vSize;
	return v;
}

/**
* Host main routine
*/

int main(int argc, char *argv[])
{

	//Mostrar especificaciones de la máquina
	int nDevices;
	clock_t start_cpu, end_cpu;
	double cpu_time_used;
	if (argc != 3){
		printf("1: fichero1, 2: fichero2  agrc %i", argc);

	}
	else{

		start_cpu = clock();
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
		}

		// Print the vector length to be used, and compute its size




		// Allocate the host input vector A
		float *h_A = NULL;

		// Allocate the host input vector B
		float *h_B = NULL;
		float *h_C = NULL;
		int tama = 0, tama1 = 0;
		h_A = readFile(argv[1], &tama);
		h_B = readFile(argv[2], &tama1);

		printf("TAMA %i\n", tama);
		size_t sizeTama = tama * sizeof(float);
		h_C = (float *)malloc(sizeTama);
		//printf("#[Vector addition of %i %i elements]\n", sizeTama, size);


		// Allocate the device input vector A
		float *d_A = NULL;
		cudaMalloc((void **)&d_A, sizeTama);


		// Allocate the device input vector B
		float *d_B = NULL;
		cudaMalloc((void **)&d_B, sizeTama);


		// Allocate the device output vector C
		float *d_C = NULL;
		cudaMalloc((void **)&d_C, sizeTama);


		// Copy the host input vectors A and B in host memory to the device input vectors in
		// device memory
		//printf("Copy input data from the host memory to the CUDA device\n");
		cudaMemcpy(d_A, h_A, sizeTama, cudaMemcpyHostToDevice);


		cudaMemcpy(d_B, h_B, sizeTama, cudaMemcpyHostToDevice);

		end_cpu = clock();
		cpu_time_used = ((double)(end_cpu - start_cpu) / (CLOCKS_PER_SEC));
		// Launch the Vector Add CUDA Kernel

		float elapsed = 0;
		cudaEvent_t start, stop;
		cudaEventCreate(&start);
		cudaEventCreate(&stop);
		cudaEventRecord(start, 0);

		int threadsPerBlock = 256;
		int blocksPerGrid = (tama + threadsPerBlock - 1) / threadsPerBlock;
		//printf("CUDA kernel launch with %d blocks of %d threads\n", blocksPerGrid, threadsPerBlock);
		vectorAdd << <blocksPerGrid, threadsPerBlock >> >(d_A, d_B, d_C, tama);
		cudaGetLastError();


		// Copy the device result vector in device memory to the host result vector
		// in host memory.
		cudaMemcpy(h_C, d_C, sizeTama, cudaMemcpyDeviceToHost);

		cudaEventRecord(stop, 0);
		cudaEventSynchronize(stop);

		cudaEventElapsedTime(&elapsed, start, stop);

		cudaEventDestroy(start);
		cudaEventDestroy(stop);
		/*for (int i = 0; i < tama; i++)
			printf("h_A[] %f +h_B[] %f =%f \n", h_A[i], h_B[i], h_C[i]);*/
		printf("%2.10f\n", cpu_time_used + elapsed);

		// Free device global memory
		cudaFree(d_A);

		cudaFree(d_B);

		cudaFree(d_C);

		// Free host memory
		free(h_A);
		free(h_B);
		free(h_C);


		// Reset the device and exit
		// cudaDeviceReset causes the driver to clean up all state. While
		// not mandatory in normal operation, it is good practice.  It is also
		// needed to ensure correct operation when the application is being
		// profiled. Calling cudaDeviceReset causes all profile data to be
		// flushed before the application exits
		cudaDeviceReset();
	}


	return 0;
}
