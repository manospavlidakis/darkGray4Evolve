# Gencode arguments                                                                                 
SMS ?= 50 52 60 61
# Generate SASS code for each SM architecture listed in $(SMS)
$(foreach sm,$(SMS),$(eval GENCODE_FLAGS += -gencode arch=compute_$(sm),code=sm_$(sm)))
# Generate PTX code from the highest SM architecture in $(SMS) to guarantee forward-compatibility
HIGHEST_SM := $(lastword $(sort $(SMS)))
GENCODE_FLAGS += -gencode arch=compute_$(HIGHEST_SM),code=compute_$(HIGHEST_SM)

#CC		:= /opt/gcc-4.8.4/bin/g++
CC		:= g++
LINKER	:= g++

CUDA = /usr/local/cuda
NVCC = $(CUDA)/bin/nvcc -ccbin $(CXX)

INCLUDES	:= -I./include
CUDA_LIBS	:= -L"$(CUDA)/lib64/"
NVCCFLAGS	:= $(CUDA_ARCH) --ptxas-options=-v 
CFLAGS		:= -std=c++11
LDFLAGS         := -lm -lX11 -lpthread
CUDA_LDFLAGS	:= $(LDFLAGS) -lrt -lcudart

all: clean ./include/CImg.h darkGray darkGrayCPU compare

CImg:
	git clone https://github.com/dtschump/CImg.git

./include/CImg.h: CImg
	ln -f -s ../CImg/CImg.h $@

darkGray: darkgray.cpp cu_darkgray.cu
	$(NVCC) $(GENCODE_FLAGS) -std=c++11 -c cu_darkgray.cu $(INCLUDES) $(NVCCFLAGS) 
	#$(NVCC) -std=c++11 -keep --resource-usage -c cu_darkgray.cu $(INCLUDES) $(NVCCFLAGS) 
	$(LINKER) -std=c++11 -o darkGray darkgray.cpp cu_darkgray.o $(INCLUDES) $(CUDA_LIBS)  $(CUDA_LDFLAGS)
	rm -f cu_darkgray.o

darkGrayCPU: darkgrayCPU.cpp c_darkgray.cpp
	$(CC) -c  c_darkgray.cpp $(INCLUDES) $(CFLAGS)
	$(LINKER) -o darkGrayCPU darkgrayCPU.cpp c_darkgray.o $(INCLUDES) $(CFLAGS) $(LDFLAGS)
	rm -f c_darkgray.o

compare: compare.cpp
	$(CC) $(INCLUDES) $< -lrt -lpthread -lX11 -o $@
	rm -rf compare.o

clean:
	-unlink include/CImg.h                                                                          
	-rm -rf bin                                                                                     
	-rm -rf lib                                                                                     
	-rm  src/vine_darkGray.o                                                                        
	-rm -rf output_images                                                                           
	-rm  src/compare.o                                                                              
	-rm -rf *.jpg 

run_img01_GPU: 
	./darkGray input_images/image01.jpg out1.jpg

run_img05_GPU: 
	./darkGray input_images/image05.jpg out5.jpg

run_im01_CPU:
	./darkGrayCPU input_images/image01.jpg cpuOut1.jpg

run_compare:
	./compare out1.jpg cpuOut1.jpg
