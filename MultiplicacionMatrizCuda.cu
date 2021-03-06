#include <stdio.h>
#include <cuda_runtime.h>

//Device Code
__global__ void VecAdd(float* A, float* B, float* C, int tam)
{
	int i = blockDim.x * blockIdx.x + threadIdx.x;
	int j = blockDim.y * blockIdx.y + threadIdx.y;
	int k = 0;
	
	if(i < tam && j < tam)
	{
		for(k = 0; k < tam; k++)
		{
			*(C +(i * tam)+ j) = *(C + (i * tam) + j) + *(A + (i * tam) + k) * *(B + (k * tam)+ j);
		}
	}	
}


int main()
{
	int tam = 1000, i = 0, j = 0;
	size_t size = tam * tam * sizeof(float);
	
	// Allocate input vectors h_A and h_B in host memory
	float* h_A = (float*) malloc (size);
	float* h_B = (float*) malloc (size);
	float* h_C = (float*) malloc (size);

	//Initialize input Vectors
	for(i=0; i < tam; i++)
	{
		for(j=0; j < tam; j++)
		{
			srand(time(NULL));
			*(h_A + (i * tam) + j) = drand48() * (10.0 - 0.0) + 0.0;
			*(h_B + (i * tam) + j) = drand48() * (10.0 - 0.0) + 0.0;
		}
	}

	//Allocate vectors in device memory
	float* d_A;
	cudaMalloc(&d_A, size);
	float* d_B;
	cudaMalloc(&d_B, size);
	float* d_C;
	cudaMalloc(&d_C, size);

	// Copy vectors from host memory to device memory
	cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_C, h_C, size, cudaMemcpyHostToDevice);

	// Invoke kernel
	dim3 dimGrid(256,256);
	dim3 dimBlock(tam,tam);

	VecAdd<<<dimGrid, dimBlock>>>(d_A, d_B, d_C, tam);
	
	// Copy result from device memory to hostmemory
	// h_C contains the result in host memory
	cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

	// Free device memory
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);
	//impresion A
/*	for(i = 0; i<tam; i++)
	{
		for(j=0; j<tam; j++)
		{			
			printf("\tA[%d][%d]= %f", i, j, *(h_A + (i * tam) + j) );			
		}
		printf("\n");
	}
	printf("\n");
	//impresion B
	for(i = 0; i<tam; i++)
	{
		for(j=0; j<tam; j++)
		{			
			printf("\tB[%d][%d]= %f",i, j, *(h_B + (i * tam) + j) );			
		}
		printf("\n");
	}
	printf("\n");
	//impresion C
	for(i = 0; i<tam; i++)
	{
		for(j=0; j<tam; j++)
		{			
			printf("\tC[%d][%d]= %f",i, j, *(h_C + (i * tam) + j) );			
		}
		printf("\n");
	}
	printf("\n");*/

	//Free host memory
	free(h_A);
	free(h_B);
	free(h_C);
}
