#include <bits/stdc++.h>
#include <chrono>

#include <cuda_runtime.h>

#define BLOCK 16 // 各ブロックは16 x 16個のスレッドから定義されるものとする．
#define WIDTH 1024 // 処理対象の行列のサイズはWIDTH x WIDTH.

// ホスト(CPU)側の行列定義．                   
float h_A[WIDTH * WIDTH];
float h_B[WIDTH * WIDTH];
float h_C[WIDTH * WIDTH];

// デバイス(GPU)側の行列へのポインタ．
float* d_A, * d_B, * d_C;

void h_multiply(float* A, float* B, float* C);
__global__ void d_multiply0(float* A, float* B, float* C);

// メイン関数．
int main()
{
	unsigned int i;

	// デバイス側に行列用のメモリを確保．
	cudaMalloc((void**)&d_A, sizeof(float) * WIDTH * WIDTH);
	cudaMalloc((void**)&d_B, sizeof(float) * WIDTH * WIDTH);
	cudaMalloc((void**)&d_C, sizeof(float) * WIDTH * WIDTH);

	// ホスト側の行列に値をセット．
	for (i = 0; i < (WIDTH * WIDTH); i++)
	{
		h_A[i] = (float)i;
		h_B[i] = (float)i;
	}

	// 計算時間の計測開始．
	auto d_start = std::chrono::system_clock::now();

	// ホスト側の行列のデータをデバイス側の行列へ転送．
	cudaMemcpy(d_A, h_A, sizeof(float) * WIDTH * WIDTH, cudaMemcpyHostToDevice);
	cudaMemcpy(d_B, h_B, sizeof(float) * WIDTH * WIDTH, cudaMemcpyHostToDevice);

	// グリッドとブロックの定義．
	dim3 grid(WIDTH / BLOCK, WIDTH / BLOCK);
	dim3 block(BLOCK, BLOCK);

	// GPU処理の起動．
	d_multiply0 <<< grid, block >>> (d_A, d_B, d_C);

	// 計算結果はd_cに格納されているので，それをホスト側のh_Cに転送．
	cudaMemcpy(h_C, d_C, sizeof(float) * WIDTH * WIDTH, cudaMemcpyDeviceToHost);

	// 計算時間の計測終了．
	auto d_end = std::chrono::system_clock::now();
	auto d_calcTime = d_end - d_start;

	// 計算結果の表示．
	std::cout << "デバイス計算時間: " << std::chrono::duration_cast<std::chrono::milliseconds>(d_calcTime).count() << "(ms) ";
	std::cout << "デバイス計算結果: " << h_C[WIDTH * WIDTH - 1] << std::endl;

	// デバイス側のメモリを解放．
	cudaFree(d_A);
	cudaFree(d_B);
	cudaFree(d_C);

	// 比較用にホスト側でも計算してみる．
	auto h_start = std::chrono::system_clock::now();
	h_multiply(h_A, h_B, h_C);
	auto h_end = std::chrono::system_clock::now();
	auto h_calcTime = h_end - h_start;
	std::cout << " ホスト計算時間: " << std::chrono::duration_cast<std::chrono::milliseconds>(h_calcTime).count() << "(ms) ";
	std::cout << " ホスト計算結果: " << h_C[WIDTH * WIDTH - 1] << std::endl;
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

__global__ void d_multiply0(float* A, float* B, float* C)
{
	unsigned int r = blockDim.y * blockIdx.y + threadIdx.y;
	unsigned int c = blockDim.x * blockIdx.x + threadIdx.x;
	unsigned int i;
	float tmp;
	tmp = 0.0f;
	for (i = 0; i < WIDTH; i++)
		tmp += A[WIDTH * r + i] * B[WIDTH * i + c];
	C[WIDTH * r + c] = tmp;
}