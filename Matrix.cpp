#include <bits/stdc++.h>

#define WIDTH 1024 // �����Ώۂ̍s��̃T�C�Y��WIDTH x WIDTH.

// �z�X�g(CPU)���̍s���`�D
float h_A[WIDTH * WIDTH];
float h_B[WIDTH * WIDTH];
float h_C[WIDTH * WIDTH];

void h_multiply(float* A, float* B, float* C);

// ���C���֐��D
int main()
{
	unsigned int i;

	// �z�X�g���̍s��ɒl���Z�b�g�D
	for (i = 0; i < (WIDTH * WIDTH); i++)
	{
		h_A[i] = (float)i;
		h_B[i] = (float)i;
	}

	// �z�X�g���ł̌v�Z���ʁD
	h_multiply(h_A, h_B, h_C);
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