#ifndef _MATMUL_H
#define _MATMUL_H

#define SIZE 4
	int A[SIZE*SIZE] = {0, 1, 2, 3,
			0, 1, 2, 3,
			0, 1, 2, 3,
			0, 1, 2, 3,
	};
	// int B[SIZE*SIZE] = {1, 2, 3, 4,
	// 	5, 6, 7, 8,
	// 	9, 10, 11, 12,
	// 	13, 14, 15, 16,
	// };
	int B[SIZE*SIZE] = {1, 5, 9, 13,
						2, 6, 10, 14,
						3, 7, 11, 15,
						4, 8, 12, 16,
	};
	int result[SIZE*SIZE];
#endif
