using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.UIElements;

public class GameOfLife : MonoBehaviour
{
    [SerializeField] private ComputeShader GOLShader;
    [SerializeField] private Material LifeMaterial;

    private enum Seed
    {
        FullTexture,
        RPentomino,
        Acorn,
        GosperGun
    }

    [SerializeField] private Seed startSeed;
    [SerializeField] private bool edgeWrap;

    [SerializeField] private Color cellColor = Color.red;
    [SerializeField][Range(0f,3f)] private float updateSpeed;
    private float timer = 0;
    private bool onState1 = true;

    private static readonly Vector2Int TexSize = new Vector2Int(512, 512);
    
    private RenderTexture State1;
    private RenderTexture State2;

    private static int Update1Kernel;
    private static int Update2Kernel;
    private static int SeedKernel;
    
    // Property ID
    private static readonly int BaseMap = Shader.PropertyToID("_BaseMap");
    private static readonly int CellColor = Shader.PropertyToID("CellColor");
    private static readonly int TextureSize = Shader.PropertyToID("TextureSize");
    private static readonly int WrapBool = Shader.PropertyToID("WrapBool");
    private static readonly int State1Tex = Shader.PropertyToID("State1");
    private static readonly int State2Tex = Shader.PropertyToID("State2");

    void Start()
    {
        State1 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };
        State1.Create();

        State2 = new RenderTexture(TexSize.x, TexSize.y, 0, DefaultFormat.LDR)
        {
            filterMode = FilterMode.Point,
            enableRandomWrite = true
        };
        State2.Create();
        
        LifeMaterial.SetTexture(BaseMap, State1);
        
        Update1Kernel = GOLShader.FindKernel("Update1");
        Update2Kernel = GOLShader.FindKernel("Update2");

        SeedKernel = startSeed switch
        {
            Seed.FullTexture => GOLShader.FindKernel("InitFullTexture"),
            Seed.RPentomino => GOLShader.FindKernel("InitRPentomino"),
            Seed.Acorn => GOLShader.FindKernel("InitAcorn"),
            Seed.GosperGun => GOLShader.FindKernel("InitGun"),
            _ => 0
        };
        
        GOLShader.SetTexture(Update1Kernel, State1Tex, State1);
        GOLShader.SetTexture(Update1Kernel, State2Tex, State2);
        
        GOLShader.SetTexture(Update2Kernel, State1Tex, State1);
        GOLShader.SetTexture(Update2Kernel, State2Tex, State2);

        GOLShader.SetTexture(SeedKernel, State1Tex, State1);

        GOLShader.SetVector(CellColor, cellColor);
        
        // bonus
        GOLShader.SetVector(TextureSize, new Vector4(TexSize.x, TexSize.y));
        GOLShader.SetBool(WrapBool, edgeWrap);
        
        GOLShader.Dispatch(SeedKernel,TexSize.x / 8, TexSize.y / 8, 1);
        
    }

    private void Update()
    {
        timer += Time.deltaTime;
        if (timer > updateSpeed)
        {
            
            LifeMaterial.SetTexture(BaseMap, onState1 ? State1 : State2);
            
            int currentUpdateKernel = onState1 ? Update1Kernel : Update2Kernel;
            GOLShader.Dispatch(currentUpdateKernel, TexSize.x / 8, TexSize.y / 8, 1);
            
            onState1 = !onState1;
            timer = 0;
        }
    }

    private void OnDisable()
    {
        State1.Release();
        State2.Release();
    }

    private void OnDestroy()
    {
        State1.Release();
        State2.Release();
    }
}