/**
 * ADO REST API client for reading/writing work items.
 * Uses System.AccessToken when running in Azure Pipelines,
 * or az CLI token for local dev.
 */

const ADO_API_VERSION = "7.1";

export interface WorkItem {
  id: number;
  fields: Record<string, unknown>;
  relations?: Array<{
    rel: string;
    url: string;
    attributes: Record<string, unknown>;
  }>;
}

export interface WorkItemCreate {
  type: string;
  title: string;
  description: string;
  areaPath?: string;
  iterationPath?: string;
  parentId?: number;
  tags?: string;
  state?: string;
}

export class AdoClient {
  private org: string;
  private project: string;
  private token: string;

  constructor(org: string, project: string, token: string) {
    this.org = org;
    this.project = project;
    this.token = token;
  }

  private get baseUrl(): string {
    return `https://dev.azure.com/${this.org}/${this.project}`;
  }

  private get headers(): Record<string, string> {
    return {
      Authorization: `Bearer ${this.token}`,
      "Content-Type": "application/json-patch+json",
    };
  }

  async getWorkItem(id: number): Promise<WorkItem> {
    const url = `${this.baseUrl}/_apis/wit/workitems/${id}?$expand=relations&api-version=${ADO_API_VERSION}`;
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${this.token}` },
    });
    if (!res.ok) throw new Error(`Failed to get work item ${id}: ${res.statusText}`);
    return res.json() as Promise<WorkItem>;
  }

  async createWorkItem(item: WorkItemCreate): Promise<WorkItem> {
    const patchDoc: Array<{ op: string; path: string; value: unknown }> = [
      { op: "add", path: "/fields/System.Title", value: item.title },
      { op: "add", path: "/fields/System.Description", value: item.description },
    ];

    if (item.areaPath) {
      patchDoc.push({ op: "add", path: "/fields/System.AreaPath", value: item.areaPath });
    }
    if (item.iterationPath) {
      patchDoc.push({ op: "add", path: "/fields/System.IterationPath", value: item.iterationPath });
    }
    if (item.tags) {
      patchDoc.push({ op: "add", path: "/fields/System.Tags", value: item.tags });
    }
    if (item.state) {
      patchDoc.push({ op: "add", path: "/fields/System.State", value: item.state });
    }
    if (item.parentId) {
      patchDoc.push({
        op: "add",
        path: "/relations/-",
        value: {
          rel: "System.LinkTypes.Hierarchy-Reverse",
          url: `${this.baseUrl}/_apis/wit/workitems/${item.parentId}`,
        },
      });
    }

    const encodedType = encodeURIComponent(item.type);
    const url = `${this.baseUrl}/_apis/wit/workitems/$${encodedType}?api-version=${ADO_API_VERSION}`;
    const res = await fetch(url, {
      method: "POST",
      headers: this.headers,
      body: JSON.stringify(patchDoc),
    });
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Failed to create ${item.type}: ${res.statusText} — ${body}`);
    }
    return res.json() as Promise<WorkItem>;
  }

  async addComment(workItemId: number, text: string): Promise<void> {
    const url = `${this.baseUrl}/_apis/wit/workitems/${workItemId}/comments?api-version=${ADO_API_VERSION}-preview.4`;
    const res = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${this.token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ text }),
    });
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Failed to add comment to ${workItemId}: ${res.statusText} — ${body}`);
    }
  }

  async updateWorkItemField(workItemId: number, field: string, value: unknown): Promise<void> {
    const url = `${this.baseUrl}/_apis/wit/workitems/${workItemId}?api-version=${ADO_API_VERSION}`;
    const res = await fetch(url, {
      method: "PATCH",
      headers: this.headers,
      body: JSON.stringify([{ op: "add", path: `/fields/${field}`, value }]),
    });
    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Failed to update ${workItemId}: ${res.statusText} — ${body}`);
    }
  }

  async addLabel(workItemId: number, label: string): Promise<void> {
    const item = await this.getWorkItem(workItemId);
    const existingTags = (item.fields["System.Tags"] as string) || "";
    const tags = existingTags ? `${existingTags}; ${label}` : label;
    await this.updateWorkItemField(workItemId, "System.Tags", tags);
  }
}
