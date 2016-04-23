module kanity.animation;

struct AnimationData(T)
{
    public bool isStarted()
    {
        return m_isStarted;
    }
    private bool m_isStarted;
    public T* ptr;
    private int frame;
    private int elapse;
    private T start;
    private T end;
    //なんかいろいろ
    //とりあえず線形補完
    public void animation()
    {
        if (m_isStarted)
        {
            *ptr = cast(int)(start + ((end - start) / cast(double)frame) * elapse);
            elapse++;
            if (elapse >= frame)
            {
                *ptr = end;
                m_isStarted = false;
            }
        }
    }
    public void setAnimation(int end, int frame)
    {
        this.start = *ptr;
        this.end = end;
        this.frame = frame;
        this.elapse = 0;
        this.m_isStarted = true;
    }

}
