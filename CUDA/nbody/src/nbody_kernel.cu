#ifndef _NBODY_KERNEL_H_
#define _NBODY_KERNEL_H_

#include "config.h"

#define prime 120247

typedef unsigned int  uint;



//! Cuda random functions from "Kurs: procesory graficzne w obliczeniach równoległych (CUDA)" 2012
__device__ uint TausStep(uint &z, int S1, int S2, int S3, uint M)  {
    uint b=(((z << S1) ^ z) >> S2);
    return z = (((z & M) << S3) ^ b);
}
__device__ uint LCGStep(uint &z, uint A, uint C) {
    return z=(A*z+C);
}
__device__ uint HybridTausInt(uint &z1, uint &z2, uint &z3, uint &z4) {
    return (
               TausStep(z1, 13, 19, 12, 4294967294UL) ^
               LCGStep( z4,    1664525, 1013904223UL)
           );
}
__device__ uint funct(uint id) {
    return HybridTausInt(id,id,id,id);
}



__device__ inline float square(float a) {
    return a*a;
}

__device__ inline float distSquare2(float4 posA, float4 posB) {
    return square((posA.x-posB.x) + square(posA.y-posB.y) + square(posA.z-posB.z));
}

__device__ inline float distSquare1(float4 posA) {
    float f = (square(posA.x*distanceMultiplier) + square(posA.y*distanceMultiplier) + square(posA.z*distanceMultiplier));
    if(f < 1.0f) f = 1.0f; 
    return f;
}

__device__ inline float dist1(float4 posA) {
    return sqrt(distSquare1(posA));
}

__device__ inline float4 sub(float4 a, float4 b){
  float4 r;  
  r.x = a.x-b.x;
    r.y = a.y-b.y;
    r.z = a.z-b.z;
    return r;
}

__device__ inline float randPos(int seed){
  return float((seed%100001))/100000.0f;
}

__device__ inline float4 normalize(float4 a) {
  float s = dist1(a);  
  a.x /= s;
  a.y /= s;
  a.z /= s;
  return a;
}

__device__ inline void move(int x, float4 *buffer, float4 *Positions, float4 *VelocityVector) {
    float4 pos = Positions[x];
    float4 vect = VelocityVector[x];
    pos.x += vect.x/10000.0f;
    pos.y += vect.y/10000.0f;
    pos.z += vect.z/10000.0f;
    buffer[x] = pos;
    Positions[x] = pos;
}

__device__ inline float4 tengent(float4 v){
    float4 u = make_float4(0.0f, 0.0f, whirlSpeed, 1.0f);
    float4 result = make_float4(u.y * v.z - u.z * v.y, u.z * v.x - u.x * v.z, u.x * v.y - u.y * v.x, 1.0f);
    float s = distSquare1(result);
    return result;
}
// kernels

__global__ void randomStatic(float4 *buffer, float4 *Positions, int seed, float4 *VelocityVector, float *Mass) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    seed = funct(seed * x * prime);
    float posX = randPos(seed);
    seed = funct(seed);
    float posY = randPos(seed);
    seed = funct(seed);
    float posZ = randPos(seed);
    Positions[x] = buffer[x] = make_float4(posX, posY, posZ, 1.0f);
    VelocityVector[x] = make_float4(0.0f, 0.0f, 0.0f, 1.0f);
    
    seed = funct(seed);
    Mass[x] = 1.0f;
}

__global__ void randomMoving(float4 *buffer, float4 *Positions, int seed, float4 *VelocityVector, float *Mass) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    seed = funct(seed * x * prime);
    float posX = randPos(seed);
    seed = funct(seed);
    float posY = randPos(seed);
    seed = funct(seed);
    float posZ = randPos(seed);
    Positions[x] = buffer[x] = make_float4(posX, posY, posZ, 1.0f);

    seed = funct(seed);
    posX = randPos(seed)*randomFactor;
    seed = funct(seed);
    posY = randPos(seed)*randomFactor;
    seed = funct(seed);
    posZ = randPos(seed)*randomFactor;

    VelocityVector[x] = make_float4(posX, posY, posZ, 1.0f);
    
    seed = funct(seed);
    Mass[x] = float(seed%401+800)/800.0f;

}

__global__ void explosion(float4 *buffer, float4 *Positions, int seed, float4 *VelocityVector, float *Mass) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    seed = funct(seed * x * prime);
    float posX = 0.0f;
    float posY = 0.0f;
    float posZ = 0.0f;
    Positions[x] = buffer[x] = make_float4(posX, posY, posZ, 1.0f);

    seed = funct(seed);
    posX = randPos(seed);
    seed = funct(seed);
    posY = randPos(seed);
    seed = funct(seed);
    posZ = randPos(seed);
    
    float4 v = make_float4(posX, posY, posZ, 1.0f);
    v = normalize(v);
    v.x *= explosionFactor;
    v.y *= explosionFactor;
    v.z *= explosionFactor;
    VelocityVector[x] = v;
    
    seed = funct(seed);
    Mass[x] = float(seed%401+800)/800.0f;

}

__global__ void explosion2(float4 *buffer, float4 *Positions, int seed, float4 *VelocityVector, float *Mass) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    seed = funct(seed * x * prime);
    float posX = 0.0f;
    float posY = 0.0f;
    float posZ = 0.0f;
    Positions[x] = buffer[x] = make_float4(posX, posY, posZ, 1.0f);

    seed = funct(seed);
    posX = randPos(seed);
    seed = funct(seed);
    posY = randPos(seed);
    seed = funct(seed);
    posZ = randPos(seed);
    
    float4 v = make_float4(posX, posY, posZ, 1.0f);
    v = normalize(v);
    v.x *= explosion2Factor;
    v.y *= explosion2Factor;
    v.z *= explosion2Factor;
    VelocityVector[x] = v;
    
    seed = funct(seed);
    Mass[x] = float(seed%401+800)/800.0f;

}

__global__ void heavyMiddle(float4 *buffer, float4 *Positions, int seed, float4 *VelocityVector, float *Mass) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    
    if(x == 0){
      Positions[x] = VelocityVector[x] = buffer[x] = make_float4(0.0f, 0.0f, 0.0f, 1.0f);
      Mass[x] = centerMass;
      return;
    }
    
    seed = funct(seed * x * prime);
    float posX = randPos(seed);
    seed = funct(seed);
    float posY = randPos(seed);
    seed = funct(seed);
    float posZ = randPos(seed);
    float4 v = make_float4(posX, posY, posZ, 1.0f);

    Positions[x] = buffer[x] = v;
    v = tengent(v);
    VelocityVector[x] = v;
    
    seed = funct(seed);
    Mass[x] = float(seed%401+800)/800.0f;

}

__global__ void simpleGravity(float4 *Positions, float4 *VelocityVector, float *Mass) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    float4 force = make_float4(0.0f, 0.0f, 0.0f, 1.0f);
    float4 p = Positions[x];
    for(int i = 0; i < bodies; i++){
        if(i == x) continue;
        float4 forceVector = make_float4(0.0f, 0.0f, 0.0f, 1.0f);
	forceVector = sub(Positions[i], p);
	float d = distSquare1(forceVector);
	forceVector = normalize(forceVector);
	float c = Mass[i]/d;
	force.x += forceVector.x * c;
	force.y += forceVector.y * c;
	force.z += forceVector.z * c;
    }

    float4 v = VelocityVector[x];
    v.x += force.x;
    v.y += force.y;
    v.z += force.z;
    VelocityVector[x] = v;
}

__global__ void improvedGravity(float4 *Positions, float4 *VelocityVector, float *Mass) {
    
    __shared__ float4 tab[threads];
    __shared__ float mass[threads];
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    float3 force = make_float3(0.0f, 0.0f, 0.0f);
    __syncthreads();
    float4 p = Positions[x];
    for(int i = 0; i < bodies; i+=threads){
	__syncthreads();
	tab[threadIdx.x] = Positions[threadIdx.x + i];
	__syncthreads();
	mass[threadIdx.x] = Mass[threadIdx.x + i];
	__syncthreads();
	for(int j = 0; j < blockDim.x; j++){
	    if(j+i == x) continue;
	    float4 forceVector = make_float4(0.0f, 0.0f, 0.0f, 1.0f);
	    forceVector = sub(tab[j], p);
	    float d = distSquare1(forceVector);
	    forceVector = normalize(forceVector);
	    float c = mass[j]/d;
	    force.x += forceVector.x * c;
	    force.y += forceVector.y * c;
	    force.z += forceVector.z * c;
	}
    }

    float4 v = VelocityVector[x];
    v.x += force.x;
    v.y += force.y;
    v.z += force.z;
    VelocityVector[x] = v;
}

__global__ void bounding(float4 *Positions, float *Borders, float* temp) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    float4 p = Positions[x];
    temp[x] = p.x;
    temp[bodies+x] = p.x;
    temp[bodies*2 + x] = p.y;
    temp[bodies*3 + x] = p.y;
    temp[bodies*4 + x] = p.z;
    temp[bodies*5 + x] = p.z;
    for(int i = 1; i < bodies; i*= 2){
      if(!(x%i)){
	if(temp[x] < temp[x+ i]) temp[x] = temp[x+ i];
	if(temp[x+bodies] > temp[x+i + bodies]) temp[x+bodies] = temp[x+i +bodies];
	if(temp[x+bodies*2] < temp[x+ i+bodies*2]) temp[x+bodies*2] = temp[x+ i +bodies*2];
	if(temp[x+bodies*3] > temp[x+ i+bodies*3]) temp[x+bodies*3] = temp[x+ i +bodies*3];
	if(temp[x+bodies*4] < temp[x+ i+bodies*4]) temp[x+bodies*4] = temp[x+ i +bodies*4];
	if(temp[x+bodies*5] > temp[x+ i+bodies*5]) temp[x+bodies*5] = temp[x+ i +bodies*5];
      }
    }
    #pragma unroll
    for(int i = 0; i < 6; i++){
      Borders[i] = temp[bodies*i];
    }
}

__global__ void shrink(float4 *buffer, float4 *Positions) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    Positions[x].x *= 0.9992f;
    Positions[x].y *= 0.9992f;
    Positions[x].z *= 0.9992f;
    buffer[x] = Positions[x];
}

__global__ void simpleMove(float4 *buffer, float4 *Positions, float4 *VelocityVector) {
    int x = blockIdx.x*blockDim.x + threadIdx.x;
    move(x, buffer, Positions, VelocityVector);
}


#endif
