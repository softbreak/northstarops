using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class DocumentVersion
{
    public int DocumentVersionId { get; set; }

    public int DocumentId { get; set; }

    public int VersionNumber { get; set; }

    public string Content { get; set; } = null!;

    public DateTime EffectiveFrom { get; set; }

    public DateTime? EffectiveTo { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual Document Document { get; set; } = null!;

    public virtual ICollection<DocumentChunk> DocumentChunks { get; set; } = new List<DocumentChunk>();
}
