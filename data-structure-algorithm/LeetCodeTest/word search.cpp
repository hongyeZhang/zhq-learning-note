// 二维搜索的回溯解决单词搜索问题
// 经典题型
class Solution
{
public:
    bool exist(vector<vector<char>>& board, string word)
    {
        m = board.size();
        assert(m >0);
        n = board[0].size();
        visited = vector<vector<bool> >(m, vector<bool>(n, false));
        for(int i=0; i<board.size();++i)
            for(int j=0; j<board[i].size(); ++j)
                if(searchWord(board, word, 0, i, j))
                    return true;
        return false;

    }
private:
    int d[4][2] = {{-1,0},{0,1},{1,0},{0,-1}};
    vector<vector<bool> >visited;
    int m,n;
    bool inArea(int x, int y)
    {
        return x>=0 && x <m && y>=0 && y<n;
    }
    //从board[startx][starty]处开始寻找word[index,...,word.size())是否存在
    bool searchWord(vector<vector<char>>& board, string word, int index, int startx, int starty)
    {
        //递归终止条件
        if(index == word.size()-1)
            return board[startx][starty] == word[index];

        if(board[startx][starty] == word[index]){
            visited[startx][starty] = true;
            for(int i =0; i<4;++i){
                int newx = startx + d[i][0];
                int newy = starty + d[i][1];
                if(inArea(newx, newy) && !visited[newx][newy] &&
                        searchWord(board, word, index+1, newx, newy))
                    return true;
            }
            visited[startx][starty] = false;
        }

        return false;


    }
};
