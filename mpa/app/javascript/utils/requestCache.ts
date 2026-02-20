// Global request deduplication with immediate locking
// Prevents duplicate requests even from parallel React mounts

const pendingRequests = new Map<string, Promise<any>>();
const requestLocks = new Set<string>();

export async function cachedFetch<T = any>(url: string, options?: RequestInit): Promise<T> {
  // IMMEDIATE synchronous lock check
  if (requestLocks.has(url)) {
    console.log(`[Cache] 🚫 Blocked (locked): ${url}`);
    // Wait for the pending request
    if (pendingRequests.has(url)) {
      return pendingRequests.get(url)!;
    }
    throw new Error('DUPLICATE_REQUEST_BLOCKED');
  }

  // Check if already pending
  if (pendingRequests.has(url)) {
    console.log(`[Cache] ♻️ Reusing pending: ${url}`);
    return pendingRequests.get(url)!;
  }

  // LOCK immediately (synchronous, before any async)
  requestLocks.add(url);
  console.log(`[Cache] ✅ New request (locked): ${url}`);
  
  const promise = fetch(url, options)
    .then(response => response.json())
    .finally(() => {
      pendingRequests.delete(url);
      // Keep lock for 100ms to block rapid duplicates
      setTimeout(() => requestLocks.delete(url), 100);
    });

  // Store promise immediately
  pendingRequests.set(url, promise);
  
  return promise;
}
