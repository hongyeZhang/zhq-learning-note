//递归和组合解决组合问题
//  可以采用剪枝进行优化 n<= n-(k-c.size())+1
class Solution
{
public:
    vector<vector<int>> combine(int n, int k)
    {
        res.clear();
        if(n<=0 || k<=0 || k>n)
            return res;
        vector<int> c;
        generateCombination(n, k, 1, c);
        return res;
    }
private:
    vector<vector<int> >res;
    //从第start个元素开始，将排列的结果放在c中，采用递归的方式解决问题
    void generateCombination(int n, int k, int start, vector<int>& c)
    {
        if(c.size() == k){
            res.push_back(c);
            return;
        }
        //递归产生子序列
        for(int i= start; i<=n; ++i){
            c.push_back(i);
            generateCombination(n, k, i+1, c);
            c.pop_back();
        }
    }

};
