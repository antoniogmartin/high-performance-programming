################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CU_SRCS += \
../src/ejemplo4.cu 

CU_DEPS += \
./src/ejemplo4.d 

OBJS += \
./src/ejemplo4.o 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.cu
	@echo 'Building file: $<'
	@echo 'Invoking: NVCC Compiler'
	nvcc -O3 -gencode arch=compute_12,code=sm_12 -odir "src" -M -o "$(@:%.o=%.d)" "$<"
	nvcc --compile -O3 -gencode arch=compute_12,code=compute_12 -gencode arch=compute_12,code=sm_12  -x cu -o  "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


