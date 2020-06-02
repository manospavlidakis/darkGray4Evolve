#include <CImg.h>
#include <iostream>
#include <iomanip>
#include <string>
#include <chrono>

using cimg_library::CImg;
using std::cout;
using std::cerr;
using std::endl;
using std::string;

extern void darkGray(const int width, const int height, const int size,  const unsigned char * inputImage, unsigned char * darkGrayImage, const int sizeOut);


int main(int argc, char *argv[]) {
	if ( argc != 3 ) {
		cerr << "Usage: " << argv[0] << " <input filename>" << " <output filename> " << endl;
		return 1;
	}

	// Load the input image
	CImg< unsigned char > inputImage = CImg< unsigned char >(argv[1]);
        cout<<"Input image size: "<<inputImage.size()<<endl;
	if ( inputImage.spectrum() != 3 ) {
		cerr << "The input must be a color image." << endl;
		return 1;
	}

	// Convert the input image to grayscale and make it darker
	CImg< unsigned char > darkGrayImage = CImg< unsigned char >(inputImage.width(), inputImage.height(),1,1,0);
        //darkGrayImage.display();
	darkGray(inputImage.width(), inputImage.height(), inputImage.size(), inputImage.data(), darkGrayImage.data(), darkGrayImage.size());
	// Save output
	darkGrayImage.save(argv[2]);
	return 0;
}
