namespace ProjectOnProjects.Common.DTOs;

public class ListItemModel<TText, TValue>
{
    public TText Text { get; set; }
    public TValue Value { get; set; }
}