#include "fir.h"

void __attribute__ ( ( section ( ".mprjram" ) ) ) initfir() {
	//initial your fir
	
	for (int i = 0; i < N; i++) {
		inputbuffer[i] = 0;
		outputsignal[i] = 0;
	}
	/*
	outputsignal[0] = 0;
	outputsignal[1] = 0;
	outputsignal[2] = 0;
	outputsignal[3] = 0;
	outputsignal[4] = 0;
	outputsignal[5] = 0;
	outputsignal[6] = 0;
	outputsignal[7] = 0;
	outputsignal[8] = 0;
	outputsignal[9] = 0;
	outputsignal[10] = 0;
	*/
	
}

int* __attribute__ ( ( section ( ".mprjram" ) ) ) fir(){
	initfir();
	//write down your fir
	
	for (int i = 0; i < N; i++) {
		for (int j = N-1; j > 0; j--) {
			inputbuffer[j] = inputbuffer[j - 1];
			outputsignal[i] += inputbuffer[j] * taps[j];
		}
		inputbuffer[0] = inputsignal[i];
		outputsignal[i] += inputbuffer[0] * taps[0];
	}
	/*
	outputsignal[0] = taps[0] * inputsignal[0];
	outputsignal[1] = taps[0] * inputsignal[1] + taps[1] * inputsignal[0];
	outputsignal[2] = taps[0] * inputsignal[2] + taps[1] * inputsignal[1] + taps[2] * inputsignal[0];
	outputsignal[3] = taps[0] * inputsignal[3] + taps[1] * inputsignal[2] + taps[2] * inputsignal[1] + taps[3] * inputsignal[0];
	outputsignal[4] = taps[0] * inputsignal[4] + taps[1] * inputsignal[3] + taps[2] * inputsignal[2] + taps[3] * inputsignal[1] + taps[4] * inputsignal[0];
	outputsignal[5] = taps[0] * inputsignal[5] + taps[1] * inputsignal[4] + taps[2] * inputsignal[3] + taps[3] * inputsignal[2] + taps[4] * inputsignal[1] + taps[5] * inputsignal[0];
	outputsignal[6] = taps[0] * inputsignal[6] + taps[1] * inputsignal[5] + taps[2] * inputsignal[4] + taps[3] * inputsignal[3] + taps[4] * inputsignal[2] + taps[5] * inputsignal[1] + taps[6] * inputsignal[0];
	outputsignal[7] = taps[0] * inputsignal[7] + taps[1] * inputsignal[6] + taps[2] * inputsignal[5] + taps[3] * inputsignal[4] + taps[4] * inputsignal[3] + taps[5] * inputsignal[2] + taps[6] * inputsignal[1] + taps[7] * inputsignal[0];
	outputsignal[8] = taps[0] * inputsignal[8] + taps[1] * inputsignal[7] + taps[2] * inputsignal[6] + taps[3] * inputsignal[5] + taps[4] * inputsignal[4] + taps[5] * inputsignal[3] + taps[6] * inputsignal[2] + taps[7] * inputsignal[1] + taps[8] * inputsignal[0];
	outputsignal[9] = taps[0] * inputsignal[9] + taps[1] * inputsignal[8] + taps[2] * inputsignal[7] + taps[3] * inputsignal[6] + taps[4] * inputsignal[5] + taps[5] * inputsignal[4] + taps[6] * inputsignal[3] + taps[7] * inputsignal[2] + taps[8] * inputsignal[1] + taps[9] * inputsignal[0];
	outputsignal[10] = taps[0] * inputsignal[10] + taps[1] * inputsignal[9] + taps[2] * inputsignal[8] + taps[3] * inputsignal[7] + taps[4] * inputsignal[6] + taps[5] * inputsignal[5] + taps[6] * inputsignal[4] + taps[7] * inputsignal[3] + taps[8] * inputsignal[2] + taps[9] * inputsignal[1] + taps[10] * inputsignal[0];
	*/
	return outputsignal;
}
		
