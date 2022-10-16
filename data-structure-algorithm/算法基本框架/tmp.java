/*
 * @Descripttion: 
 * @version: 
 * @Author: ZhangHongye
 * @Date: 2022-10-15 11:26:28
 */
int binarySearch(int[] nums, int target) {
    int left = 0, right = nums.length - 1;
    while(left<=right) {
        int mid = left + (right-left)/2;
        if(mid == target) {
            left = mid + 1;
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else if (nums[mid] > target) {
            right = mid - 1;
        }
    }
    while(right < 0 || nums[right] != target) {
        return -1;
    }
    return right;
}