using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class DocumentChunk
{
    public int DocumentChunkId { get; set; }

    public int DocumentVersionId { get; set; }

    public int ChunkIndex { get; set; }

    public string ChunkText { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public virtual DocumentVersion DocumentVersion { get; set; } = null!;

    public virtual ICollection<Retrieval> Retrievals { get; set; } = new List<Retrieval>();
}
