#include <bits/stdc++.h>

#include <cuda_runtime.h>
#include <timer.h>

#define BLOCK 16 // �e�u���b�N��16 x 16�̃X���b�h�����`�������̂Ƃ���D
#define WIDTH 1024 // �����Ώۂ̍s��̃T�C�Y��WIDTH x WIDTH.

// �z�X�g(CPU)���̍s���`�D
float h_A[WIDTH * WIDTH];
float h_B[WIDTH * WIDTH];
float h_C[WIDTH * WIDTH];

// �f�o�C�X(GPU)���̍s��ւ̃|�C���^�D
float* d_A, * d_B, * d_C;

void h_multiply(float* A, float* B, float* C);
__global__ void d_multiply0(float* A, float* B, float* C);

// ���C���֐��D
int main()
{
	unsigned int i;

	// �f�o�C�X���ɍs��p�̃��������m�ہD
	cudaMalloc((void**)&d_A, sizeof(float) * WIDTH * WIDTH);
	cudaMalloc((void**)&d_B, sizeof(float) * WIDTH * WIDTH);
	cudaMalloc((void**)&d_C, sizeof(float) * WIDTH * WIDTH);

	// �z�X�g���̍s��ɒl���Z�b�g�D
	for (i = 0; i < (WIDTH * WIDTH); i++)
	{
		h_A[i] = (float)i;
		h_B[i] = (float)i;
	}

	// �v�Z���Ԍv���p�̃^�C�}�[�̃Z�b�g�D
	StartTimer();

	// �z�X�g���̍s��̃f�[�^���f�o�C�X���̍s��֓]���D
	cudaMemcpy(d_A, h_A, sizeof(float) * WIDTH * WIDTH);
	cudaMemcpy(d_B, h_B, sizeof(float) * WIDTH * WIDTH);

	// �O���b�h�ƃu���b�N�̒�`�D
	dim3 grid(WIDTH / BLOCK, WIDTH / BLOCK);
	dim3 block(BLOCK, BLOCK);

	// GPU�����̋N���D
	d_multiply0 <<< grid, block >> > (d_A, d_B, d_C);

	// �v�Z���ʂ�d_c�Ɋi�[����Ă���̂ŁC������z�X�g����h_C�ɓ]���D
	cudaMemcpy(h_c, d_c, sizeof(float) * WIDTH * WIDTH, cudaMemcpyDeviceToHost);

	// �v�Z���ʂ̕\���D
	std::cout << "�f�o�C�X�v�Z����: " << GetTimer() << "(ms) ";
	std::cout << "�f�o�C�X�v�Z����: " << h_c[WIDTH * WIDTH - 1] << std::endl;

	// �f�o�C�X���̃�����������D
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);

	// ��r�p�Ƀz�X�g���ł��v�Z���Ă݂�D
	StartTimer();
	h_multiply(h_A, h_B, h_C);
	std::cout << " �z�X�g�v�Z����: " << GetTimer() << " ";
	std::cout << " �z�X�g�v�Z����: " << h_C[WIDTH * WIDTH - 1] << std::endl;
}

void h_multiply(float* A, float* B, float* C)
{
	unsigned int r, c, i;
	float tmp;
	for (r = 0; r < WIDTH; r++) {
		for (c = 0; c < WIDTH; c++) {
			tmp = 0.0;
			for (i = 0; i < WIDTH; i++)
				tmp += A[WIDTH * r + i] * B[WIDTH * i + c];
			C[WIDTH * r + c] = tmp;
		}
	}
}