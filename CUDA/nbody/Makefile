#change this to fit your installation
CUDA_INSTALL_PATH = /usr/local/cuda
CUDA_SDK_PATH = /opt/NVIDIA_GPU_Computing_SDK
LCUTIL_VERSION = -lcutil_i386  # -lcutil_x86_64

#↓uncomment when nvcc not in PATH
#NVCC = $(CUDA_INSTALL_PATH)/bin/nvcc
NVCC = nvcc


# Paths
INC = -I. -I$(CUDA_SDK_PATH)/C/common/inc
LIB = -L$(CUDA_SDK_PATH)/C/lib -lcuda $(LCUTIL_VERSION) -lglut -lGLEW 

# Program-specific
TARGET= nbody
SOURCES = ./src/nbody.cu


# Flags
NVCCFLAGS = -03


$(TARGET) : $(SOURCES)
	$(NVCC) -o $(TARGET) $(SOURCES) $(INC) $(LIB)

clean:
	rm -f $(TARGET)
