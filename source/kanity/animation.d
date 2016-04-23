module kanity.animation;
import std.experimental.logger;

struct AnimationData(T){
    public bool isStarted()
    {
        return m_isStarted;
    }
    private bool m_isStarted;
    public T delegate() getter;
    public void delegate(T) setter;
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
            setter(cast(T)(start + ((end - start) / cast(double)frame) * elapse));
            elapse++;
            if (elapse >= frame)
            {
                setter(end);
                m_isStarted = false;
            }
        }
    }
    public void setAnimation(T end, int frame)
    {
        this.start = getter();
        this.end = end;
        this.frame = frame;
        this.elapse = 0;
        this.m_isStarted = true;
    }

}
