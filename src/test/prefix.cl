kernel void prefix_sum(global const float *a, global float *b, global float *sum) {
    uint id = get_local_id(0);
    uint size = get_local_size(0);
    uint gid = get_group_id(0);
    uint offset = 1;

    local float tmp[2 * SIZE];
    tmp[2 * id] = a[2 * id + gid * (2 * size)];
    tmp[2 * id + 1] = a[2 * id + 1 + gid * (2 * size)];

    for (int d = size; d > 0; d >>= 1, offset *= 2) {
        barrier(CLK_LOCAL_MEM_FENCE);
        if (id < d) {
            int ai = offset * (2 * id + 1) - 1;
            int bi = offset * (2 * id + 2) - 1;
            tmp[bi] += tmp[ai];
        }
    }

    if (id == 0) {
        sum[gid] = tmp[2 * size - 1];
        tmp[2 * size - 1] = 0;
    }

    for (int d = 1; d <= size; d *= 2) {
        offset >>= 1;
        barrier(CLK_LOCAL_MEM_FENCE);
        if (id < d) {
            int ai = offset * (2 * id + 1) - 1;
            int bi = offset * (2 * id + 2) - 1;
            float t = tmp[ai];
            tmp[ai] = tmp[bi];
            tmp[bi] += t;
        }
    }

    barrier(CLK_LOCAL_MEM_FENCE);
    b[2 * id + gid * (2 * size)] = tmp[2 * id];
    b[2 * id + 1 + gid * (2 * size)] = tmp[2 * id + 1];
}

kernel void add(global float *a, global const float *sum) {
    uint id = get_local_id(0);
    uint size = get_local_size(0);
    uint gid = get_group_id(0);

    a[2 * id + gid * (2 * size)] += sum[gid];
    a[2 * id + 1 + gid * (2 * size)] += sum[gid];
}