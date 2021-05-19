kernel void matrix_mul(global const float *a, global const float *b, global float *c, uint N, uint K, uint M) {
    uint localRow = get_local_id(0);
    uint localCol = get_local_id(1);

    uint globalRow = TILE_W * get_group_id(0) + localRow;
    uint globalCol = TILE_H * get_group_id(1) + localCol;
    
    local float aa[E_THREAD][TS][TILE_W];
    local float bb[TS][TILE_H];

    float res[E_THREAD];
    for (int i = 0; i < E_THREAD; i++) {
        res[i] = 0;
    }

    uint numTiles = K / TS;
    for (int t = 0; t < numTiles; t++) {
        if (localCol < TS) {
            for (int j = 0; j < E_THREAD; j++) {
                aa[j][localCol][localRow] = a[(j * (N / E_THREAD) + globalRow) * K + (t * TS + localCol)];
            }
        }
        if (localRow < TS) {
            bb[localRow][localCol] = b[(t * TS + localRow) * M + globalCol];
        }

        barrier(CLK_LOCAL_MEM_FENCE);

        for (int j = 0; j < E_THREAD; j++) {
            for (int i = 0; i < TS; i++) {
                res[j] += aa[j][i][localRow] * bb[i][localCol];
            }
        }

        barrier(CLK_LOCAL_MEM_FENCE);
    }

    for (int i = 0; i < E_THREAD; i++) {
        c[(i * (N / E_THREAD) + globalRow) * M + globalCol] = res[i];
    }
}