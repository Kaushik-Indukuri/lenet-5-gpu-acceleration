#include <cmath>
#include <iostream>
#include "gpu-new-forward.h"
#define TILE_WIDTH 20
__constant__ float constMask[5000];

__global__ void conv_forward_kernel(float *output, const float *input, const float *mask, const int B, const int M, const int C, const int H, const int W, const int K, const int S)
{
    /*
    Modify this function to implement the forward pass described in Chapter 16.
    We have added an additional dimension to the tensors to support an entire mini-batch
    The goal here is to be correct AND fast.

    Function paramter definitions:
    output - output
    input - input
    mask - convolution kernel
    B - batch_size (number of images in x)
    M - number of output feature maps
    C - number of input feature maps
    H - input height dimension
    W - input width dimension
    K - kernel height and width (K x K)
    S - stride step length
    */

    const int H_out = (H - K) / S + 1;
    const int W_out = (W - K) / S + 1;
    // (void)H_out; // silence declared but never referenced warning. remove this line when you start working
    // (void)W_out; // silence declared but never referenced warning. remove this line when you start working

    // We have some nice #defs for you below to simplify indexing. Feel free to use them, or create your own.
    // An example use of these macros:
    // float a = in_4d(0,0,0,0)
    // out_4d(0,0,0,0) = a

#define out_4d(i3, i2, i1, i0) output[(i3) * (M * H_out * W_out) + (i2) * (H_out * W_out) + (i1) * (W_out) + i0]
#define in_4d(i3, i2, i1, i0) input[(i3) * (C * H * W) + (i2) * (H * W) + (i1) * (W) + i0]
#define mask_4d(i3, i2, i1, i0) constMask[(i3) * (C * K * K) + (i2) * (K * K) + (i1) * (K) + i0]

    // Insert your GPU convolution kernel code here
    const int W_grid = (W_out + TILE_WIDTH - 1) / TILE_WIDTH;

    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int b = blockIdx.x;
    int m = blockIdx.y;

    int h = (blockIdx.z / W_grid) * TILE_WIDTH + ty;
    int w = (blockIdx.z % W_grid) * TILE_WIDTH + tx;

    if (h < H_out && w < W_out)
    {
        float acc = 0.0f;
        for (int c = 0; c < C; c++)
        {
            if (K == 3)
            {
                acc += in_4d(b, c, h * S + 0, w * S + 0) * mask_4d(m, c, 0, 0);
                acc += in_4d(b, c, h * S + 0, w * S + 1) * mask_4d(m, c, 0, 1);
                acc += in_4d(b, c, h * S + 0, w * S + 2) * mask_4d(m, c, 0, 2);

                acc += in_4d(b, c, h * S + 1, w * S + 0) * mask_4d(m, c, 1, 0);
                acc += in_4d(b, c, h * S + 1, w * S + 1) * mask_4d(m, c, 1, 1);
                acc += in_4d(b, c, h * S + 1, w * S + 2) * mask_4d(m, c, 1, 2);

                acc += in_4d(b, c, h * S + 2, w * S + 0) * mask_4d(m, c, 2, 0);
                acc += in_4d(b, c, h * S + 2, w * S + 1) * mask_4d(m, c, 2, 1);
                acc += in_4d(b, c, h * S + 2, w * S + 2) * mask_4d(m, c, 2, 2);
            }

            if (K == 7)
            {
                acc += in_4d(b, c, h * S + 0, w * S + 0) * mask_4d(m, c, 0, 0);
                acc += in_4d(b, c, h * S + 0, w * S + 1) * mask_4d(m, c, 0, 1);
                acc += in_4d(b, c, h * S + 0, w * S + 2) * mask_4d(m, c, 0, 2);
                acc += in_4d(b, c, h * S + 0, w * S + 3) * mask_4d(m, c, 0, 3);
                acc += in_4d(b, c, h * S + 0, w * S + 4) * mask_4d(m, c, 0, 4);
                acc += in_4d(b, c, h * S + 0, w * S + 5) * mask_4d(m, c, 0, 5);
                acc += in_4d(b, c, h * S + 0, w * S + 6) * mask_4d(m, c, 0, 6);

                acc += in_4d(b, c, h * S + 1, w * S + 0) * mask_4d(m, c, 1, 0);
                acc += in_4d(b, c, h * S + 1, w * S + 1) * mask_4d(m, c, 1, 1);
                acc += in_4d(b, c, h * S + 1, w * S + 2) * mask_4d(m, c, 1, 2);
                acc += in_4d(b, c, h * S + 1, w * S + 3) * mask_4d(m, c, 1, 3);
                acc += in_4d(b, c, h * S + 1, w * S + 4) * mask_4d(m, c, 1, 4);
                acc += in_4d(b, c, h * S + 1, w * S + 5) * mask_4d(m, c, 1, 5);
                acc += in_4d(b, c, h * S + 1, w * S + 6) * mask_4d(m, c, 1, 6);

                acc += in_4d(b, c, h * S + 2, w * S + 0) * mask_4d(m, c, 2, 0);
                acc += in_4d(b, c, h * S + 2, w * S + 1) * mask_4d(m, c, 2, 1);
                acc += in_4d(b, c, h * S + 2, w * S + 2) * mask_4d(m, c, 2, 2);
                acc += in_4d(b, c, h * S + 2, w * S + 3) * mask_4d(m, c, 2, 3);
                acc += in_4d(b, c, h * S + 2, w * S + 4) * mask_4d(m, c, 2, 4);
                acc += in_4d(b, c, h * S + 2, w * S + 5) * mask_4d(m, c, 2, 5);
                acc += in_4d(b, c, h * S + 2, w * S + 6) * mask_4d(m, c, 2, 6);

                acc += in_4d(b, c, h * S + 3, w * S + 0) * mask_4d(m, c, 3, 0);
                acc += in_4d(b, c, h * S + 3, w * S + 1) * mask_4d(m, c, 3, 1);
                acc += in_4d(b, c, h * S + 3, w * S + 2) * mask_4d(m, c, 3, 2);
                acc += in_4d(b, c, h * S + 3, w * S + 3) * mask_4d(m, c, 3, 3);
                acc += in_4d(b, c, h * S + 3, w * S + 4) * mask_4d(m, c, 3, 4);
                acc += in_4d(b, c, h * S + 3, w * S + 5) * mask_4d(m, c, 3, 5);
                acc += in_4d(b, c, h * S + 3, w * S + 6) * mask_4d(m, c, 3, 6);

                acc += in_4d(b, c, h * S + 4, w * S + 0) * mask_4d(m, c, 4, 0);
                acc += in_4d(b, c, h * S + 4, w * S + 1) * mask_4d(m, c, 4, 1);
                acc += in_4d(b, c, h * S + 4, w * S + 2) * mask_4d(m, c, 4, 2);
                acc += in_4d(b, c, h * S + 4, w * S + 3) * mask_4d(m, c, 4, 3);
                acc += in_4d(b, c, h * S + 4, w * S + 4) * mask_4d(m, c, 4, 4);
                acc += in_4d(b, c, h * S + 4, w * S + 5) * mask_4d(m, c, 4, 5);
                acc += in_4d(b, c, h * S + 4, w * S + 6) * mask_4d(m, c, 4, 6);

                acc += in_4d(b, c, h * S + 5, w * S + 0) * mask_4d(m, c, 5, 0);
                acc += in_4d(b, c, h * S + 5, w * S + 1) * mask_4d(m, c, 5, 1);
                acc += in_4d(b, c, h * S + 5, w * S + 2) * mask_4d(m, c, 5, 2);
                acc += in_4d(b, c, h * S + 5, w * S + 3) * mask_4d(m, c, 5, 3);
                acc += in_4d(b, c, h * S + 5, w * S + 4) * mask_4d(m, c, 5, 4);
                acc += in_4d(b, c, h * S + 5, w * S + 5) * mask_4d(m, c, 5, 5);
                acc += in_4d(b, c, h * S + 5, w * S + 6) * mask_4d(m, c, 5, 6);

                acc += in_4d(b, c, h * S + 6, w * S + 0) * mask_4d(m, c, 6, 0);
                acc += in_4d(b, c, h * S + 6, w * S + 1) * mask_4d(m, c, 6, 1);
                acc += in_4d(b, c, h * S + 6, w * S + 2) * mask_4d(m, c, 6, 2);
                acc += in_4d(b, c, h * S + 6, w * S + 3) * mask_4d(m, c, 6, 3);
                acc += in_4d(b, c, h * S + 6, w * S + 4) * mask_4d(m, c, 6, 4);
                acc += in_4d(b, c, h * S + 6, w * S + 5) * mask_4d(m, c, 6, 5);
                acc += in_4d(b, c, h * S + 6, w * S + 6) * mask_4d(m, c, 6, 6);
            }
        }
        out_4d(b, m, h, w) = acc;
    }

#undef out_4d
#undef in_4d
#undef mask_4d
}

__host__ void GPUInterface::conv_forward_gpu_prolog(const float *host_output, const float *host_input, const float *host_mask, float **device_output_ptr, float **device_input_ptr, float **device_mask_ptr, const int B, const int M, const int C, const int H, const int W, const int K, const int S)
{
    // Allocate memory and copy over the relevant data structures to the GPU

    // We pass double pointers for you to initialize the relevant device pointers,
    //  which are passed to the other two functions.

    // Useful snippet for error checking
    // cudaError_t error = cudaGetLastError();
    // if(error != cudaSuccess)
    // {
    //     std::cout<<"CUDA error: "<<cudaGetErrorString(error)<<std::endl;
    //     exit(-1);
    // }
    const int H_out = (H - K) / S + 1;
    const int W_out = (W - K) / S + 1;

    cudaMalloc((void **)device_output_ptr, (B * M * H_out * W_out) * sizeof(float));
    cudaMalloc((void **)device_input_ptr, (B * C * H * W) * sizeof(float));
    cudaMalloc((void **)device_mask_ptr, (M * C * K * K) * sizeof(float));

    cudaMemcpy(*device_input_ptr, host_input, (B * C * H * W) * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(constMask, host_mask, (M * C * K * K) * sizeof(float));
}

__host__ void GPUInterface::conv_forward_gpu(float *device_output, const float *device_input, const float *device_mask, const int B, const int M, const int C, const int H, const int W, const int K, const int S)
{
    // Set the kernel dimensions and call the kernel
    const int H_out = (H - K) / S + 1;
    const int W_out = (W - K) / S + 1;
    int W_grid = ceil((float)W_out / TILE_WIDTH);
    int H_grid = ceil((float)H_out / TILE_WIDTH);
    int Y = W_grid * H_grid;

    dim3 dimGrid(B, M, Y);
    dim3 dimBlock(TILE_WIDTH, TILE_WIDTH, 1);
    conv_forward_kernel<<<dimGrid, dimBlock>>>(device_output, device_input, device_mask, B, M, C, H, W, K, S);
}

__host__ void GPUInterface::conv_forward_gpu_epilog(float *host_output, float *device_output, float *device_input, float *device_mask, const int B, const int M, const int C, const int H, const int W, const int K, const int S)
{
    const int H_out = (H - K) / S + 1;
    const int W_out = (W - K) / S + 1;
    int outSize = B * M * H_out * W_out;

    // Copy the output back to host
    cudaMemcpy(host_output, device_output, outSize * sizeof(float), cudaMemcpyDeviceToHost);

    // Free device memory
    cudaFree(device_output);
    cudaFree(device_input);
    cudaFree(device_mask);
}

__host__ void GPUInterface::get_device_properties()
{
    int deviceCount;
    cudaGetDeviceCount(&deviceCount);

    for (int dev = 0; dev < deviceCount; dev++)
    {
        cudaDeviceProp deviceProp;
        cudaGetDeviceProperties(&deviceProp, dev);

        std::cout << "Device " << dev << " name: " << deviceProp.name << std::endl;
        std::cout << "Computational capabilities: " << deviceProp.major << "." << deviceProp.minor << std::endl;
        std::cout << "Max Global memory size: " << deviceProp.totalGlobalMem << std::endl;
        std::cout << "Max Constant memory size: " << deviceProp.totalConstMem << std::endl;
        std::cout << "Max Shared memory size per block: " << deviceProp.sharedMemPerBlock << std::endl;
        std::cout << "Max threads per block: " << deviceProp.maxThreadsPerBlock << std::endl;
        std::cout << "Max block dimensions: " << deviceProp.maxThreadsDim[0] << " x, " << deviceProp.maxThreadsDim[1] << " y, " << deviceProp.maxThreadsDim[2] << " z" << std::endl;
        std::cout << "Max grid dimensions: " << deviceProp.maxGridSize[0] << " x, " << deviceProp.maxGridSize[1] << " y, " << deviceProp.maxGridSize[2] << " z" << std::endl;
        std::cout << "Warp Size: " << deviceProp.warpSize << std::endl;
    }
}