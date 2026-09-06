using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Message
{
    public long MessageId { get; set; }

    public long RunId { get; set; }

    public int SequenceNumber { get; set; }

    public string Role { get; set; } = null!;

    public string Content { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public virtual Run Run { get; set; } = null!;
}
