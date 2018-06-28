/**
* Vector addition: C = A + B.
*
* This sample is a very basic sample that implements element by element
* vector addition. It is the same as the sample illustrating Chapter 2
* of the programming guide with some additions like error checking.
*/
#include <time.h>
#include <time.h>
#include <stdio.h>

#include <stdlib.h>
// For the CUDA runtime routines (prefixed with "cuda_")

/**
* CUDA Kernel Device code
*
* Computes the vector addition of A and B into C. The 3 vectors have the same
* number of elements numElements.
*/
void vectorAdd(const float *A, const float *B, float *C, int numElements)
{
	 float ai, bi, res=0;
	int j=0;
	for (int i = 0; i < numElements; i++){		
	   
	    ai = A[i];

	    bi=B[i];

	    if (i < numElements)
	    {
		for (j=0;j<10000;j++) res+=(ai*bi)/742;
		C[i]=A[i]+B[i];
	
	    }
	}
}
//GETLINE FOR NOT-POSIX
float * readFile(char * path, int * n){

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
	if (argc != 3){
		printf("1: fichero1, 2: fichero2\n");

	}
	else{


		//Mostrar especificaciones de la máquina
		
		clock_t start_cpu, end_cpu;
		double cpu_time_used;

		start_cpu = clock();



			// Allocate the host input vector A
			float *h_A = NULL;

			// Allocate the host input vector B
			float *h_B = NULL;
			float *h_C = NULL;

			int tama = 0, tama1 = 0;
			// Verify that allocations succeeded
			h_A = readFile(argv[1], &tama);
			h_B = readFile(argv[2], &tama1);


			printf("#TAMA %i\n", tama);
			size_t sizeTama = tama * sizeof(float);
			h_C = (float *)malloc(sizeTama);


			vectorAdd(h_A, h_B, h_C, tama);
		end_cpu = clock();

		cpu_time_used = ((double)(end_cpu - start_cpu) / (CLOCKS_PER_SEC));
		printf("%10.65f\n", cpu_time_used);

		/*for(int i=0;i<tama;i++){
			printf("hA %f hB %f hC %f\n",h_A[i],h_B[i],h_C[i]);
		}
		*/


		// Free host memory
		free(h_A);
		free(h_B);
		free(h_C);
	}

	return 0;
}
