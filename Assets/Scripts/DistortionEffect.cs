using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistortionEffect : PostEffectBase {
    [Range(0, 1)]
    [Header("热扰动强度")]
    public float distortStrength = 0.8f;

    [Range(0, 1)]
    [Header("热扰动速率")]
    public float distortVelocity = 0.5f;

    [Header("噪声水平密度")]
    public float xDensity = 1.0f;

    [Header("噪声数值密度")]
    public float yDensity = 1.0f;

    [Header("噪声纹理")]
    public Texture noiseTexture = null;

    public void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if(material) {
            material.SetFloat("_DistortStrength", distortStrength);
            material.SetFloat("_DistortVelocity", distortVelocity);
            material.SetFloat("_XDensity", xDensity);
            material.SetFloat("_YDensity", yDensity);
            material.SetTexture("_NoiseTex", noiseTexture);

            Graphics.Blit(source, destination, material);
        }
        else {
            Graphics.Blit(source, destination);
        }
    }
}
