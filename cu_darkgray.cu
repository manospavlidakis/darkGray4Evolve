#include <iostream>
#include <iomanip>
#include <chrono>
//#include <CImg.h>
//#define TIMERS

//using cimg_library::CImg;
using std::cout;
using std::cerr;
using std::endl;

/* Kernel for the device */
__global__ void rgb_gray(const int width, const int height,
        const unsigned char *inputImage,
        unsigned char *darkGrayImage) {
    int x;
    int y;

    // calculate the thread index for both x, y, by the use of the dimension
    // of the block the id of the current block and the id of the thread
    y = blockDim.y * blockIdx.y + threadIdx.y;
    x = blockDim.x * blockIdx.x + threadIdx.x;

    // check if we are out of bounds
    if ((y * width + x) > (width * height)) {
        return;
    }
    // do the transformation
    float grayPix = 0.0f;
    float r = static_cast<float>(inputImage[(y * width) + x]);
    float g = static_cast<float>(inputImage[(width * height) + (y * width) + x]);
    float b =
        static_cast<float>(inputImage[(2 * width * height) + (y * width) + x]);
    grayPix = ((0.3f * r) + (0.59f * g) + (0.11f * b));
    grayPix = (grayPix * 0.6f) + 0.5f;
    darkGrayImage[(y * width) + x] = static_cast<unsigned char>(grayPix);
}
// End Kernel
// Host
void darkGray(const int width, const int height, const int size, 
        const unsigned char *inputImage, unsigned char *darkGrayImage, 
        const int sizeOut) {
    unsigned char *inputImageDev;			// Input image on device
    unsigned char *darkGrayImageDev;		// Output image on device
    int size_image, outImageSize;			// Size of the image
    /* Find the size of the image */
    size_image = size * sizeof(*inputImage);
    outImageSize = sizeOut * sizeof(*darkGrayImage);

#ifdef TIMERS
    /* timer for input creation */
    std::chrono::time_point<std::chrono::system_clock> start, stop;
    start = std::chrono::system_clock::now();
#endif

    if (cudaMalloc((void**)&inputImageDev, size_image) != cudaSuccess) {
        cerr << "Cuda Malloc FAILED " << endl;
    }
    if (cudaMalloc((void**)&darkGrayImageDev, outImageSize) != cudaSuccess) {
        cerr << "Cuda Malloc FAILED " << endl;
    }
    
    cudaMemset(darkGrayImageDev, 0 , outImageSize);

#ifdef TIMERS
    stop = std::chrono::system_clock::now();
    std::chrono::duration<double> elapsed = stop - start;
    cout << "DarkGray malloc: " << elapsed.count() << " sec." << endl;
    /*timer for input creation*/
    start = std::chrono::system_clock::now();
#endif

    //transfer image from  host to device
    if (cudaMemcpy(inputImageDev, inputImage, size_image , cudaMemcpyHostToDevice)!=cudaSuccess){
        cerr << "Cuda MemCpy H2D FAILED " << endl;
    }

#ifdef TIMERS
    stop = std::chrono::system_clock::now();
    elapsed = stop - start;
    cout << "DarkGray H2D: " << elapsed.count() << " sec." << endl;

    /*timer for input creation*/
    start = std::chrono::system_clock::now();
#endif

    //find the width of the block
    int wBlock = static_cast<unsigned int>(ceil(width / static_cast<float>(32)));
    int hBlock = static_cast<unsigned int>(ceil(height / static_cast<float>(16)));

    //execution configuration
    dim3 dimGrid(wBlock,hBlock);//grid dimensions: (wBlock*hBlock) thread blocks
    dim3 dimBlock(32 , 16);//block dimensions: 32*16=512 threads per block

    //launch the kernel with dimGrid num of blocks and dimBlock num of threads eac
    rgb_gray<<<dimGrid, dimBlock>>>(width, height, inputImageDev,darkGrayImageDev);

    cudaError_t err = cudaGetLastError();

#ifdef TIMERS
    cudaDeviceSynchronize();

    stop = std::chrono::system_clock::now();
    elapsed = stop - start;
    cout<<std::fixed << "DarkGray kernel: " << elapsed.count() << " sec." << endl;

    /*timer for input creation*/
    start = std::chrono::system_clock::now();
#endif

    if (err != cudaSuccess) 
        cerr << "Error: " << cudaGetErrorString(err) << endl;

    if (cudaMemcpy(darkGrayImage, darkGrayImageDev, outImageSize, cudaMemcpyDeviceToHost)!=cudaSuccess){
        cerr << "Cuda MemCpy D2H FAILED "<<endl;
    }
#ifdef TIMERS
    stop = std::chrono::system_clock::now();
    elapsed = stop - start;
    cout << "DarkGray D2H: " << elapsed.count() << " sec." << endl;

    /*timer for input creation*/
    start = std::chrono::system_clock::now();
#endif

    //clean up
    cudaFree(inputImageDev);
    cudaFree(darkGrayImageDev);

#ifdef TIMERS
    stop = std::chrono::system_clock::now();
    elapsed = stop - start;
    cout << "DarkGray Free: " << elapsed.count() << " sec." << endl;
#endif
}
