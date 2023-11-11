Shader "Custom/IntersectionGlow"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {
            Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _IntersectionColor;
            CBUFFER_END
            
            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD1;
            };
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                return output;
            }
            
            float4 frag (Varyings input) : SV_TARGET
            {
                float2 screenUV = GetNormalizedScreenSpaceUV(input.positionHCS);
                
                float depthTexture = LinearEyeDepth(SampleSceneDepth(screenUV), _ZBufferParams);
                
                float depthObject = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);
                float lerpValue = pow (1 - saturate(depthTexture - depthObject), 10);
                return lerp(_Color, _IntersectionColor, lerpValue);
            }
            
            ENDHLSL
        }
    }
}