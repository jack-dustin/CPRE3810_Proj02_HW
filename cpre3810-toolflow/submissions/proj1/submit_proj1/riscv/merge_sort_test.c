@ -0,0 +1,107 @@
/** This file implements the Merge Sort Algorithm
 *
 * Merge Sort recursively divides the array by 2 until each element it by itself
 * It then rebuilds (merges) the array, sorting it while doing so.
 * 
 * @author Isaiah Pridie
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdint.h>
#include <omp.h>

// prototypes
void merge(uint64_t left, uint64_t middle, uint64_t right, uint16_t arr[]);
double mergeSort(uint16_t arr[], uint64_t size, int threadCount);
void mergeSortRecurse(uint64_t left, uint64_t right, uint16_t arr[]);


double mergeSort(uint16_t arr[], uint64_t size, int threadCount){
    double end_time;
    double start_time;
    #pragma omp barrier // wait for all threads

    threadCount++;  // do something so I don't get a warning
    threadCount--;
    start_time = omp_get_wtime();

    if (size == 0 || size == 1) { return 1; } // no array or already sorted 
    // threadCount will be used soon for parallelizing once I get down the serial version
    mergeSortRecurse(0, size - 1, arr);

    #pragma omp barrier // all threads should end together
    end_time = omp_get_wtime();
    return end_time - start_time;
}

// divide step
void mergeSortRecurse(uint64_t left, uint64_t right, uint16_t arr[]) {
    if (left < right) { // if left == right, stop splitting -> 1 element left
        uint64_t middle = (left + right) / 2;   // find mid point. Int div on purpose

        mergeSortRecurse(left, middle, arr);         // Recursively sort left half 
        mergeSortRecurse(middle + 1, right, arr);    // Recursively sort right half

        merge(left, middle, right, arr);     // Merge Right Half and Left Half
    }
}  

void merge(uint64_t left, uint64_t middle, uint64_t right, uint16_t arr[]) {
    uint64_t sizeLeft = (middle - left + 1);
    uint64_t sizeRight = (right - middle);
    uint64_t i;

    // Create different Arrays for left and right halves
    uint16_t *leftArray = NULL;
    uint16_t *rightArray = NULL;
    leftArray = (uint16_t *)malloc(sizeLeft * sizeof(uint16_t));
    rightArray = (uint16_t *)malloc(sizeRight * sizeof(uint16_t));
    if (leftArray == NULL || rightArray == NULL) {
        printf("MergeSort malloc() failed\n");
        free(leftArray);
        free(rightArray);
        return;
    }

    // Load values of half into an array
    for (i = 0; i < sizeLeft; i++) {
        leftArray[i] = arr[left + i];
    }   // Filling new left half array

    for (i = 0; i < sizeRight; i++) {
        rightArray[i] = arr[middle + 1 + i];
    }   // Filling new right half array

    // For merging the right & left arrays back into 1 array:
    i = 0;
    uint64_t j = 0;
    uint64_t k = left;
    // sort while merging; pull smallest value from either array
    while ( (i < sizeLeft) && (j < sizeRight) ) {
        if (leftArray[i] <= rightArray[j]) {
            arr[k] = leftArray[i];
            i++;
        } else {
            arr[k] = rightArray[j];
            j++;
        }
        k++;
    }   // End while

    // When 1 array is depleted before the other, move remaining elements int arr
    while (i < sizeLeft) {  // when left array has elements remaining
        arr[k] = leftArray[i];
        i++;
        k++;   
    }

    while (j < sizeRight) { // when right array has elements remaining
        arr[k] = rightArray[j];
        j++;
        k++;
    }
    free(leftArray);    // clean up from malloc()
    free(rightArray);
}   // end merge()