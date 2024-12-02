import { defineConfig } from 'vite';
import electron from 'vite-plugin-electron';

export default defineConfig({
    plugins: [
        electron({
            entry: 'src/main.ts',
        }),
    ],
    build: {
        rollupOptions: {
            external: ['@grpc/grpc-js', '@grpc/proto-loader']
        }
    },
    optimizeDeps: {
        exclude: ['@grpc/grpc-js', '@grpc/proto-loader']
    }
});