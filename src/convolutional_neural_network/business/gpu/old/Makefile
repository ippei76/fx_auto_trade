#Makefile

INCLUDE = -I ./cudaHeader
NVCC = nvcc
DIVIDEOPTION = -arch=sm_20 -rdc=true
SOURCEFILES = JnaInterface.cu cnnMain.cu convolution.cu activate.cu pooling.cu check.cu deviceAccesser.cu hostAccesser.cu
OBJFILES  = $(SOURCEFILES:.cu=.o)
EXECFILES = $(SOURCEFILES:.cu=)
LIBOPTION = -shared -Xcompiler -fPIC
WARNOPTION = -Wall -W


#libJnaInterface.so: JnaInterface.o cnnMain.o check.o convolution.o activate.o pooling.o deviceAccesser.o hostAccesser.o
libJnaInterface.so:
	#$(NVCC) $(LIBOPTION) $(DIVIDEOPTION) -o libJnaInterface.so JnaInterface.o cnnMain.o check.o convolution.o activate.o pooling.o deviceAccesser.o hostAccesser.o $(INCLUDE)
	$(NVCC) $(LIBOPTION) $(DIVIDEOPTION) -o libJnaInterface.so JnaInterface.cu cnnMain.cu check.cu convolution.cu activate.cu pooling.cu deviceAccesser.cu hostAccesser.cu $(INCLUDE)
	#$(NVCC) $(LIBOPTION) $(DIVIDEOPTION) -o libcnnMain.so cnnMain.cu check.cu convolution.cu activate.cu pooling.cu deviceAccesser.cu hostAccesser.cu $(INCLUDE)
	#$(NVCC) $(LIBOPTION) $(DIVIDEOPTION) -o libcnnMain.so cnnMain.o check.o convolution.o activate.o pooling.o deviceAccesser.o hostAccesser.o $(INCLUDE)

convolution: convolution.o check.o deviceAccesser.o hostAccesser.o
	$(NVCC) $(DIVIDEOPTION) -o convolution convolution.o deviceAccesser.o $(INCLUDE)

activate: activate.o check.o deviceAccesser.o hostAccesser.o
	$(NVCC) $(DIVIDEOPTION) activate activate.o deviceAccesser.o $(INCLUDE)

pooling: pooling.o check.o deviceAccesser.o hostAccesser.o
	$(NVCC) $(DIVIDEOPTION) pooling pooling.o deviceAccesser.o $(INCLUDE)

JnaInterface.o: cnnMain.cu JnaInterface.cu
	$(NVCC) -c JnaInterface.cu $(INCLUDE)

cnnMain.o: cnnMain.cu
	$(NVCC) -c cnnMain.cu $(INCLUDE)

convolution.o: convolution.cu deviceAccesser.cu
	$(NVCC) $(DIVIDEOPTION) -c convolution.cu deviceAccesser.cu hostAccesser.cu $(INCLUDE)
	
activate.o: activate.cu deviceAccesser.cu
	$(NVCC) $(DIVIDEOPTION) -c activate.cu deviceAccesser.cu hostAccesser.cu $(INCLUDE)

pooling.o: pooling.cu deviceAccesser.cu
	$(NVCC) $(DIVIDEOPTION) -c pooling.cu deviceAccesser.cu hostAccesser.cu $(INCLUDE)

check.o: check.cu deviceAccesser.cu
	$(NVCC) $(DIVIDEOPTION) -c check.cu deviceAccesser.cu hostAccesser.cu $(INCLUDE)

deviceAccesser.o: deviceAccesser.cu
	$(NVCC) -c deviceAccesser.cu $(INCLUDE)

hostAccesser.o: hostAccesser.cu
	$(NVCC) -c hostAccesser.cu $(INCLUDE)

.PHONY: clean
clean:
	rm -f $(OBJFILES)
	rm -f $(EXECFILES)

