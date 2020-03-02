class Solution
{
public:
    int rob(vector<int>& nums)
    {
        if(nums.size() ==0)
            return 0;
        memo = vector<int>(nums.size(), -1);
        return getRob(nums, 0);
    }
private:
    //考虑自[index...nums.size())中打劫获得的最大收益记忆数组
    vector<int> memo;
    //考虑自[index...nums.size())中打劫获得的最大收益状态函数
    int getRob(vector<int>& nums, int index)
    {
        if(index >= nums.size())
            return 0;
        if(memo[index] != -1)
            return memo[index];
        int res = -1;
        for(int i= index; i<nums.size();++i){
            res = max(res, nums[i] + getRob(nums, i+2));
        }
        memo[index] = res;
        return res;
    }
};

//同样可以使用动态规划的方法，自底向上解决问题
