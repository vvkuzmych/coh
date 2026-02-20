// Shared TypeScript types for the application

export type DocumentStatus = 'uploaded' | 'reviewed' | 'signed' | 'archived';

export interface Document {
  id: string;
  title: string;
  content: string;
  status: DocumentStatus;
  score?: number;
  created_at?: string;
  updated_at?: string;
  user_id?: number;
}

export interface SearchResult {
  id: string;
  title: string;
  content: string;
  status: DocumentStatus;
  score: number;
  highlights?: {
    title?: string[];
    content?: string[];
  };
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface DocumentApiResponse extends ApiResponse {
  document?: Document;
}

export interface SearchApiResponse extends ApiResponse {
  results?: SearchResult[];
  total?: number;
  took?: number;
}
