#include <iostream>
#include <iomanip>

using std::cout;
using std::cerr;
using std::endl;


void darkGray(const int width, const int height, const unsigned char * inputImage, unsigned char * darkGrayImage) {
	// Kernel
	for ( int y = 0; y < height; y++ ) {
		for ( int x = 0; x < width; x++ ) {
			float grayPix = 0.0f;
			float r = static_cast< float >(inputImage[(y * width) + x]);
			float g = static_cast< float >(inputImage[(width * height) + (y * width) + x]);
			float b = static_cast< float >(inputImage[(2 * width * height) + (y * width) + x]);

			grayPix = ((0.3f * r) + (0.59f * g) + (0.11f * b));
			grayPix = (grayPix * 0.6f) + 0.5f;

			darkGrayImage[(y * width) + x] = static_cast< unsigned char >(grayPix);
		}
	}	
}
