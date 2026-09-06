using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Retrieval
{
    public long RetrievalId { get; set; }

    public long RunId { get; set; }

    public int DocumentChunkId { get; set; }

    public int RankPosition { get; set; }

    public decimal? Score { get; set; }

    public DateTime RetrievedAt { get; set; }

    public virtual DocumentChunk DocumentChunk { get; set; } = null!;

    public virtual Run Run { get; set; } = null!;
}
