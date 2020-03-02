//相当于用递归的方法解决排列组合的问题

class Solution
{
public:
    vector<string> letterCombinations(string digits)
    {
        res.clear();
        if(digits == "")
            return res;
        findCombination(digits, 0, "");

        return res;

    }
private:
    vector<string> res;
    const string letterMap[10]={
        " ",//0
        "",
        "abc",//2
        "def",//3
        "ghi",//4
        "jkl",//5
        "mno",//6
        "pqrs",//7
        "tuv",//8
        "wxyz"//9
        };
    //采用递归算法，寻找第index个数字的组合结果
    void findCombination(string digits, int index, const string &s)  //这个位置s需要添加const
    {
        if(index == digits.size()){
            res.push_back(s);
            return;
        }

        char c = digits[index];
        string str = letterMap[c-'0'];
        for(int i=0; i<str.size();++i){
            findCombination(digits, index+1, s+str[i]);
        }

    }
};
