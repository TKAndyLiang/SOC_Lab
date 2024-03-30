#ifndef _FUNCTION_H
#define _FUNCTION_H

#define SIZE 4
#define SIZE_QS 10
#define N 11
	// matrix multiplication
	int A[SIZE*SIZE] = {
			0, 1, 2, 3,
			0, 1, 2, 3,
			0, 1, 2, 3,
			0, 1, 2, 3,
	};
	int B[SIZE*SIZE] = {
		1, 2, 3, 4,
		5, 6, 7, 8,
		9, 10, 11, 12,
		13, 14, 15, 16,
	};
	int result[SIZE*SIZE];
	
	// quick sort
	int QS[SIZE_QS] = {893, 40, 3233, 4267, 2669, 2541, 9073, 6023, 5681, 4622};

	// fir
	int taps[N] = {0,-10,-9,23,56,63,56,23,-9,-10,0};
	int inputbuffer[N];
	int inputsignal[N] = {1,2,3,4,5,6,7,8,9,10,11};
	int outputsignal[N];
#endif
