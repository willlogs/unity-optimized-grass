using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpritePainter : MonoBehaviour
{
    [SerializeField] private SpriteRenderer _sr;

    private void Start(){
        print(_sr.sprite.texture.width);
        print(_sr.sprite.texture.height);
    }
}
