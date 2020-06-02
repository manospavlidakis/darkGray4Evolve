#include <CImg.h>
#include <iostream>
#include <iomanip>
#include <string>
#include <chrono>

using cimg_library::CImg;
using std::cout;
using std::cerr;
using std::endl;
using std::fixed;
using std::setprecision;
using std::string;

extern void darkGray(const int width, const int height, const unsigned char * inputImage, unsigned char * darkGrayImage);


int main(int argc, char *argv[]) {
    int i; 

	if ( argc != 3 ) {
        cerr << "Usage: " << argv[0] << " <input filename> <output filename>" << endl;
        return 1;
    }

	// Load the input image
	CImg< unsigned char > inputImage = CImg< unsigned char >(argv[1]);
	if ( inputImage.spectrum() != 3 ) {
		cerr << "The input must be a color image." << endl;
		return 1;
	}

	// Convert the input image to grayscale and make it darker
	CImg<unsigned char> darkGrayImage = CImg<unsigned char>(inputImage.width(), 
                                                            inputImage.height(), 1, 1);

	for(i=0; i<100; ++i) {
		/*timer for input creation*/
    	std::chrono::time_point<std::chrono::system_clock> startKernel, stopKernel;
    	startKernel = std::chrono::system_clock::now();
		
		darkGray(inputImage.width(), inputImage.height(), 
    	         inputImage.data(), darkGrayImage.data());

		stopKernel  = std::chrono::system_clock::now();
	    std::chrono::duration<double> elapsed = stopKernel - startKernel;
	    cout << "DarkGray CPU took: " << elapsed.count() << " sec." << endl;
	}

	// Save output
	darkGrayImage.save(argv[2]);

	return 0;
}
