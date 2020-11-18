using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CommandBufferForDistortMask : MonoBehaviour {
    private CommandBuffer _cb;
    private Renderer _renderer;
    private Material _material;
    private int _maskId = 0;

    private void Awake() {
        _maskId = Shader.PropertyToID("_MaskTex");
    }

    private void OnEnable() {
        _renderer = gameObject.GetComponent<Renderer>();
        _material = _renderer.sharedMaterial;

        _cb = new CommandBuffer();
        _cb.name = "Draw Distort";
        _cb.GetTemporaryRT(_maskId, -2, -2);
        _cb.SetRenderTarget(_maskId);
        _cb.ClearRenderTarget(true, true, Color.black);
        _cb.DrawRenderer(_renderer, _material);

        Camera cam = Camera.main;
        cam.depthTextureMode = DepthTextureMode.Depth;
        cam.AddCommandBuffer(CameraEvent.AfterForwardOpaque, _cb);
    }

    private void OnDisable() {
        Camera.main.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, _cb);
        _cb.ReleaseTemporaryRT(_maskId);
        _cb.Clear();
    }
}
