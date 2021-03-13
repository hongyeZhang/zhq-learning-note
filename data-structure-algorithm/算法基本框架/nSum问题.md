

## 2 Sum 问题

### 问题描述1
如果假设输入一个数组 nums 和一个目标和 target，请你返回 nums 中能够凑出 target 的两个元素的值，比如输入 nums = [1,3,5,6], target = 9，
那么算法返回两个元素 [3,6]。可以假设只有且仅有一对儿元素可以凑出 target。

### 解决思路1
* 前提是返回数组的值，而不是索引，所以可以将原来的数组进行排序
* 先对数据排序，然后指定 left right 指针，比较 sum(nums[left]+nums[right]) 与 target 的值大小，根据大小调整指针的增减
```java
int[] twoSum(int[] nums, int target) {
    int left = 0, right = nums.length - 1;
    while (left < right) {
        int sum = nums[left] + nums[right];
        if (sum == target) {
            return new int[]{left, right};
        } else if (sum < target) {
            left++; // 让 sum 大一点
        } else if (sum > target) {
            right--; // 让 sum 小一点
        }
    }
    // 不存在这样两个数
    return new int[]{-1, -1};
}
```

### 问题描述2
同描述1，数组是无序的，返回对应数据的 index
### 解决思路2
* 建立一个map，存储组成target 所需要的另一个数的值和 index，然后从头开始遍历数组，找出对应的值
* 时间: O(n)   空间：O(n)















