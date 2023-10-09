Shader"Custom/TestShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry"}
        

        Pass{
            Name "OmaPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        HLSLPROGRAM

        #pragma vertex VertexFunction
        #pragma fragment FragmentFunction

        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

        struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
        };

        struct Varyings // Or use v2f, whichever you find intuitive in the future.
        {
            float4 positionHCS : SV_POSITION;
            float3 normalWS : TEXCOORD0;

        };

        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        CBUFFER_END


        Varyings VertexFunction(const Attributes input)
        {
            Varyings output;
            output.positionHCS = TransformObjectToHClip(input.positionOS);
            //output.positionWS = TransformObjectToWorld(input.positionOS);
            
            // In world coordinates = changes when rotated
            output.normalWS = TransformObjectToWorldNormal(input.normalOS);

            // In own coordinates = doesn't change when rotated
            //output.normalWS = input.normalOS;
            return output;
        }

        float4 FragmentFunction(const Varyings input) : SV_Target
        {
            //return _Color * float4((input.positionWS.x + 1) / 2, (input.positionWS.y + 1) / 2, (input.positionWS.z + 1) / 2, 1);
            //return _Color * clamp(input.positionWS.x, 0, 1);
            return _Color * float4(abs(input.normalWS),1);
        }


        ENDHLSL        

        }
    }
}