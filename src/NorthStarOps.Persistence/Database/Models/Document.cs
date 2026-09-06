using System;
using System.Collections.Generic;

namespace NorthStarOps.Persistence.Database.Models;

public partial class Document
{
    public int DocumentId { get; set; }

    public string DocumentCode { get; set; } = null!;

    public string Title { get; set; } = null!;

    public string DocumentType { get; set; } = null!;

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public virtual ICollection<DocumentVersion> DocumentVersions { get; set; } = new List<DocumentVersion>();
}
