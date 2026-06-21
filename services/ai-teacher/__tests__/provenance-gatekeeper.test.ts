import { enforceProvenance } from '../provenance/provenance-gatekeeper';

// NOTE: Test runner globals (describe/it/expect) may not be configured in this repo yet.
// These tests are scaffolding and will be enabled once the test environment is set up.
const describe = (name: string, fn: () => void) => fn();
const it = (name: string, fn: () => void | Promise<void>) => void fn();
const expect = (value: any) => ({
  toBe: (v: any) => {
    if (value !== v) throw new Error(`Expected ${v} but got ${value}`);
  }
});

describe('provenance gatekeeper', () => {
  it('blocks when reference span ingestion_status is not complete', () => {

    const required = ['span-1'];
    const referenceSpansById = {
      'span-1': {
        referenceSpanId: 'span-1',
        workId: 'work-1',
        ingestion_status: 'missing'
      }
    } as const;

    const res = enforceProvenance(required, referenceSpansById);
    expect(res.allowed).toBe(false);
    expect(res.provenance.status).toBe('missing');
  });

  it('allows when ingestion_status is complete', () => {
    const required = ['span-1'];
    const referenceSpansById = {
      'span-1': {
        referenceSpanId: 'span-1',
        workId: 'work-1',
        ingestion_status: 'complete'
      }
    } as const;

    const res = enforceProvenance(required, referenceSpansById);
    expect(res.allowed).toBe(true);
    expect(res.provenance.status).toBe('complete');
  });
});

