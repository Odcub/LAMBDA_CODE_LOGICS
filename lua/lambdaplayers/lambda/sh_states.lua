-- Shared state definitions placeholder for Lambda Players.
-- This file exists so that AddCSLuaFile and include calls won't fail when the shared
-- state functionality is relocated. Module authors can expand this file with shared
-- helper functions or small client-side state logic as required.

if SERVER then return end

-- Client-side: stub helper to request server state info if needed.
-- Keep this file minimal to avoid introducing logic duplication.

-- Example helper (no-op):
function LambdaRequestStateInfo() end
